defmodule Linguist.MemorizedVocabulary do
  alias Linguist.Cldr.Number.Cardinal
  alias Linguist.{Compiler, LocaleError, NoTranslationError}

  defmodule TranslationDecodeError do
    defexception [:message]
  end

  @moduledoc """
  Looks up translations loaded at runtime from YAML files, with binding
  interpolation.

  Locales are loaded with the `locale/2` function, given a locale name and the
  path to a YAML file of translations. The translations are stored in a named
  ETS table, so they can be looked up from any process.

  The ETS table is created by, and owned by, the process that loads the first
  locale. Only that process can load more locales, and the table is deleted
  when it exits, so load all the locales from a long-lived process, such as
  during application start.

  For example, given `es.yml`:

      flash:
        notice:
          hello: "hola %{first} %{last}"
      users:
        title: "Usuarios"
      apple:
        one: "%{count} manzana"
        other: "%{count} manzanas"

  Load it:

      Linguist.MemorizedVocabulary.locale("es", Path.join([__DIR__, "es.yml"]))

  Then look up its translations:

      iex> Linguist.MemorizedVocabulary.t("es", "flash.notice.hello", first: "Alex", last: "Smith")
      {:ok, "hola Alex Smith"}
      iex> Linguist.MemorizedVocabulary.t!("es", "users.title")
      "Usuarios"
  """

  @doc """
  Looks up the translation for `path` in `locale`, interpolating `bindings`.

  * locale - The String or atom name of the locale, e.g. "en", "fr-FR". It is
    normalized to the format "ll" or "ll-LL" before lookup
  * path - The String dot-separated path of the translation, e.g. "flash.notice.hello"
  * bindings - The Keyword list of values to interpolate into the translation.
    If it includes the configured `:pluralization_key`, the plural form for that
    value is looked up

  Returns `{:ok, translation}`, or `{:error, :no_translation}` when no
  translation is found. Raises `Linguist.LocaleError` for a `nil` or malformed
  locale, and `KeyError` when a binding used by the translation is missing.

  ## Examples

      iex> Linguist.MemorizedVocabulary.t("es", "flash.notice.hello", first: "Alex", last: "Smith")
      {:ok, "hola Alex Smith"}
      iex> Linguist.MemorizedVocabulary.t("es", "apple", count: 2)
      {:ok, "2 manzanas"}
      iex> Linguist.MemorizedVocabulary.t("ES", "flash.missing")
      {:error, :no_translation}
  """
  @spec t(String.t() | atom(), String.t(), keyword()) ::
          {:ok, String.t()} | {:error, :no_translation}
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

  @doc """
  Looks up the translation for `path` in `locale`, interpolating `bindings`.

  Works as `t/3`, but returns the translation itself, and raises
  `Linguist.NoTranslationError` when no translation is found.

  ## Examples

      iex> Linguist.MemorizedVocabulary.t!("es", "apple", count: 1)
      "1 manzana"
  """
  @spec t!(String.t() | atom(), String.t(), keyword()) :: String.t()
  def t!(locale, path, bindings \\ []) do
    case t(locale, path, bindings) do
      {:ok, translation} ->
        translation

      {:error, :no_translation} ->
        raise %NoTranslationError{message: "#{locale}: #{path}"}
    end
  end

  @spec do_t(String.t(), String.t(), keyword()) ::
          {:ok, String.t()} | {:error, :no_translation}
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
              # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
              key = String.to_atom(String.trim_trailing(rest, "}"))

              acc <> to_string(Keyword.fetch!(bindings, key))

            segment, acc ->
              acc <> segment
          end)

        {:ok, translation}
    end
  end

  @doc """
  Returns the names of the locales that have been loaded with `locale/2`,
  most recently loaded first.

  The translations registry is created when the first locale is loaded, so
  this raises `ArgumentError` if `locale/2` has not been called yet. Returns
  `nil` if the registry exists but no locale has been added to it.
  """
  @spec locales() :: [String.t()] | nil
  def locales do
    tuple =
      :ets.lookup(:translations_registry, "memorized_vocabulary.locales")
      |> List.first()

    if tuple do
      elem(tuple, 1)
    end
  end

  @doc """
  Adds `name` to the list of loaded locales returned by `locales/0`.

  Called by `locale/2`, which should be used to load a locale.
  """
  @spec add_locale(String.t()) :: true
  def add_locale(name) do
    current_locales = locales() || []

    :ets.insert(
      :translations_registry,
      {"memorized_vocabulary.locales", [name | current_locales]}
    )
  end

  @doc """
  Stores the translations in `loaded_source` for `locale_name`.

  * locale_name - The String name of the locale, e.g. "en", "fr"
  * loaded_source - A map of dot-separated translation paths to translation
    strings, as returned by `_load_yaml_file/1`

  Called by `locale/2`, which should be used to load a locale.
  """
  @spec update_translations(String.t(), %{String.t() => String.t()}) :: [true]
  def update_translations(locale_name, loaded_source) do
    loaded_source
    |> Enum.map(fn {key, translation_string} ->
      :ets.insert(:translations_registry, {"#{locale_name}.#{key}", translation_string})
    end)
  end

  @doc """
  Loads the translations in a YAML file for a locale.

  * name - The String name of the locale, e.g. "en", "fr-FR". Use the format
    "ll" or "ll-LL", as locales are normalized to this format when
    translations are looked up
  * source - The String path to a YAML file of translations

  Raises `ArgumentError` if called from a process other than the one that
  loaded the first locale.

  ## Examples

      locale("es", Path.join([__DIR__, "es.yml"]))
  """
  @spec locale(String.t(), Path.t()) :: true
  def locale(name, source) do
    loaded_source = Linguist.MemorizedVocabulary._load_yaml_file(source)
    update_translations(name, loaded_source)
    add_locale(name)
  end

  @doc """
  Loads a YAML file into a map of dot-separated translation paths to translations.

  Used internally by the `locale/2` function, which should be used to load a
  YAML file of translations.
  """
  @spec _load_yaml_file(Path.t()) :: %{String.t() => String.t()}
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
  Recursive function used internally for loading YAML files.

  Not intended for external use.
  """
  @spec _yaml_reducer({String.t(), term()}, acc) :: acc
        when acc: %{paths: %{String.t() => String.t()}, current_prefix: String.t()}
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

  @doc """
  Normalizes a locale name to the format "ll" or "ll-LL".

  If the locale contains a `-`, it is split on the `-`, the first part is
  downcased and the second part is upcased. A locale without a `-` is
  downcased. Raises `Linguist.LocaleError` if the locale contains more than
  one `-`.

  ## Examples

      iex> Linguist.MemorizedVocabulary.normalize_locale("FR-fr")
      "fr-FR"
      iex> Linguist.MemorizedVocabulary.normalize_locale("ES")
      "es"
  """
  @spec normalize_locale(String.t()) :: String.t()
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
