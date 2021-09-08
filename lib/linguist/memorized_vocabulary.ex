defmodule Linguist.MemorizedVocabulary do
  alias Linguist.Cldr.Number.Cardinal
  alias Linguist.Compiler
  alias Linguist.{LocaleError, NoTranslationError}

  defmodule TranslationDecodeError do
    defexception [:message]
  end

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
  def t(locale, path, bindings \\ [])
  def t(nil, _, _), do: raise(LocaleError, nil)

  def t(locale, path, binding) when is_atom(locale) do
    t(to_string(locale), path, binding)
  end

  def t(locale, path, bindings) do
    pluralization_key = Application.fetch_env!(:linguist, :pluralization_key)
    norm_locale = normalize_locale(locale)

    if Keyword.has_key?(bindings, pluralization_key) do
      plural_atom =
        bindings
        |> Keyword.get(pluralization_key)
        |> Cardinal.plural_rule(norm_locale)

      do_t(norm_locale, "#{path}.#{plural_atom}", bindings)
    else
      do_t(norm_locale, path, bindings)
    end
  end

  def t!(locale, path, bindings \\ []) do
    case t(locale, path, bindings) do
      {:ok, translation} ->
        translation

      {:error, :no_translation} ->
        raise %NoTranslationError{message: "#{locale}: #{path}"}
    end
  end

  # sobelow_skip ["DOS.StringToAtom"]
  defp do_t(locale, translation_key, bindings) do
    case :ets.lookup(:translations_registry, "#{locale}.#{translation_key}") do
      [] ->
        {:error, :no_translation}

      [{_, string}] ->
        translation =
          Compiler.interpol_rgx()
          |> Regex.split(string, on: [:head, :tail])
          |> Enum.reduce("", fn
            <<"%{" <> rest>>, acc ->
              key = String.to_atom(String.trim_trailing(rest, "}"))

              acc <> to_string(Keyword.fetch!(bindings, key))

            segment, acc ->
              acc <> segment
          end)

        {:ok, translation}
    end
  end

  def locales do
    tuple =
      :ets.lookup(:translations_registry, "memorized_vocabulary.locales")
      |> List.first()

    if tuple do
      elem(tuple, 1)
    end
  end

  def add_locale(name) do
    current_locales = locales() || []
    new_locales = [name | current_locales] |> Enum.uniq()

    :ets.insert(
      :translations_registry,
      {"memorized_vocabulary.locales", new_locales}
    )
  end

  def update_translations(locale_name, loaded_source) do
    loaded_source
    |> Enum.map(fn {key, translation_string} ->
      :ets.insert(:translations_registry, {"#{locale_name}.#{key}", translation_string})
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
    name = normalize_locale(name)
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

    {decode_status, [file_data]} = YamlElixir.read_all_from_file(source)

    if decode_status != :ok do
      raise %TranslationDecodeError{message: "Decode failed for file #{source}"}
    end

    %{paths: paths} =
      file_data
      |> Enum.reduce(
        %{paths: %{}, current_prefix: ""},
        &Linguist.MemorizedVocabulary._yaml_reducer/2
      )

    paths
  end

  @doc """
  Recursive function used internally for loading yaml files.
  Not intended for external use
  """
  def _yaml_reducer({key, value}, acc) when is_binary(value) do
    key_name =
      if acc.current_prefix == "" do
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
    next_prefix =
      if acc.current_prefix == "" do
        key
      else
        "#{acc.current_prefix}.#{key}"
      end

    reduced =
      Enum.reduce(
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

  # @privatedoc
  # Takes a locale as an argument, checks if the string contains a `-`, if so
  # splits the string on the `-` downcases the first part and upcases the second part.
  # With a locale that contains no `-` the string is downcased, and if the locale contains more
  # than one `-`, a LocaleError is raised.
  def normalize_locale(locale) when is_atom(locale), do: normalize_locale(to_string(locale))

  def normalize_locale(locale) do
    if String.match?(locale, ~r/-/) do
      case String.split(locale, "-") do
        [lang, country] ->
          Enum.join([String.downcase(lang), String.upcase(country)], "-")

        _ ->
          raise(LocaleError, locale)
      end
    else
      String.downcase(locale)
    end
  end
end
