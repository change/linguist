defmodule Linguist.MemorizedVocabulary do
  alias Linguist.Compiler
  alias Linguist.NoTranslationError
  alias Cldr.Number.Cardinal

  @moduledoc """
  Defines lookup functions for given translation locales, binding interopolation

  Locales are defined with the `locale/2` function, accepting a locale name and
  a String path to evaluate for the translations list.

  For example, given the following translations :

  locale "en", [
    flash: [
      notice: [
        hello: "hello %{first} %{last}",
      ]
    ],
    users: [
      title: "Users",
    ]
  ]

  locale "fr", Path.join([__DIR__, "fr.exs"])

  this module will respond to these functions :

  t("en", "flash.notice.hello", bindings \\ []), do: # ...
  t("en", "users.title", bindings \\ []), do: # ...
  t("fr", "flash.notice.hello", bindings \\ []), do: # ...
  """

  def t(locale, path, bindings \\ []) do
    pluralization_key = Application.fetch_env!(:linguist, :pluralization_key)
    if Keyword.has_key?(bindings, pluralization_key) do
      plural_atom =
        Cardinal.plural_rule(
          Keyword.get(bindings, pluralization_key),
          locale
        )

      new_path = "#{path}.#{plural_atom}"
      do_t(locale, new_path, bindings)
    else
      do_t(locale, path, bindings)
    end
  end

  def t!(locale, path, bindings \\ []) do
    case t(locale, path, bindings) do
      {:ok, translation} -> translation
      {:error, :no_translation} ->
        raise %NoTranslationError{message: "#{locale}: #{path}"}
    end
  end

  defp do_t(locale, translation_key, bindings \\ []) do
    case :ets.lookup(:translations_registry, "#{locale}.#{translation_key}") do
      [] -> {:error, :no_translation}
      [{_, string}] ->
        translation =
          Compiler.interpol_rgx()
          |> Regex.split(string, on: [:head, :tail])
          |> Enum.reduce("", fn
            <<"%{" <> rest>>, acc ->
              key = String.to_atom(String.rstrip(rest, ?}))

              acc <> to_string(Keyword.fetch!(bindings, key))
            segment, acc ->
              acc <> segment
            end)
        {:ok, translation}
    end
  end

  def locales do
    tuple = :ets.lookup(:translations_registry, "memorized_vocabulary.locales")
    |> List.first()
    if tuple do
      elem(tuple, 1)
    end
  end

  def add_locale(name) do
    if locales() do
      :ets.insert(:translations_registry, {"memorized_vocabulary.locales", [name | locales()]})
    else
      :ets.insert(:translations_registry, {"memorized_vocabulary.locales", [name]})
    end
  end

  def update_translations(name, loaded_source) do
    loaded_source
    |> Enum.map(fn({key, translation_string}) ->
      :ets.insert(:translations_registry, {"#{name}.#{key}", translation_string})
    end)
  end

  @doc """
  Embeds locales from provided source

  * name - The String name of the locale, ie "en", "fr"
  * source - The String file path to load YAML from that returns a structured list of translations

  Examples

  locale "es", Path.join([__DIR__, "es.yml"])
  """
  def locale(name, source) do
    loaded_source = Linguist.MemorizedVocabulary._load_yaml_file(source)
    update_translations(name, loaded_source)
    add_locale(name)
  end

  @doc """
  Function used internally to load a yaml file. Please use
  the `locale` macro with a path to a yaml file - this function
  will not work as expected if called directly.
  """
  def _load_yaml_file(source) do
    if :ets.info(:translations_registry) == :undefined do
      :ets.new(:translations_registry, [:named_table, :set, :protected])
    end

    {:ok, [file_data]} = Yomel.decode_file(source)

    %{paths: paths} = file_data
    |> Enum.reduce(%{paths: %{}, current_prefix: ""}, &Linguist.MemorizedVocabulary._yaml_reducer/2)
    paths
  end

  @doc """
  Recursive function used internally for loading yaml files.
  Not intended for external use
  """
  def _yaml_reducer({key, value}, acc) when is_binary(value) do
    key_name = if acc.current_prefix == "" do
      key
    else
      "#{acc.current_prefix}.#{key}"
    end

    %{ 
      paths: Map.put(acc.paths, key_name, value),
      current_prefix: acc.current_prefix
    }
  end
  def _yaml_reducer({key, value}, acc) do
    next_prefix = if acc.current_prefix == "" do
      key
    else
      "#{acc.current_prefix}.#{key}"
    end

    reduced = Enum.reduce(
      value,
      %{
        paths: acc.paths,
        current_prefix: next_prefix
      },
      &Linguist.MemorizedVocabulary._yaml_reducer/2
    )

    %{
      paths: Map.merge(acc.paths, reduced.paths),
      current_prefix: acc.current_prefix
    }
  end
end
