defmodule Linguist.Compiler do
  alias Linguist.Cldr.Number.Cardinal
  alias Linguist.NoTranslationError

  @doc ~S"""
  Compiles keyword list of transactions into function definitions AST

  Examples

  iex> Linguist.Compiler.compile(en: [
    hello: "Hello %{name}",
    alert: "Alert!"
  ])

  quote do
    def t(locale, path, binding \\ [])

    def t("en", "hello", bindings), do: "Hello " <> Keyword.fetch!(bindings, :name)
    def t("en", "alert", bindings), do: "Alert!"

    def t(_locale, _path, _bindings), do: {:error, :no_translation}
    def t!(locale, path, bindings \\ []) do
      case t(locale, path, bindings) do
        {:ok, translation} -> translation
        {:error, :no_translation} ->
          raise %NoTranslationError{message: "#{locale}: #{path}"}
      end
    end
  end
  """

  @interpol_rgx ~r/
                   (?<head>)
                   (?<!%) %{.+?}
                   (?<tail>)
                   /x
  def interpol_rgx do
    @interpol_rgx
  end

  @escaped_interpol_rgx ~r/%%{/
  @simple_interpol "%{"

  def compile(translations) do
    langs = translations |> Enum.reduce([], fn item, acc ->
      case item do
        {name, _paths} -> acc ++ [to_string(name)]
        _ -> acc
      end
    end)

    translations =
      for {locale, source} <- translations do
        deftranslations(to_string(locale), "", source)
      end

    quote do
      def t(locale, path, binding \\ [])

      def t(locale, path, binding) when is_atom(locale) do
        t(to_string(locale), path, binding)
      end

      def t(locale, path, bindings) do
        if Keyword.has_key?(bindings, @pluralization_key) do
          plural_atom =
            bindings
            |> Keyword.get(@pluralization_key)
            |> Cardinal.plural_rule(locale)

          new_path = "#{path}.#{plural_atom}"
          do_t(locale, new_path, bindings)
        else
          do_t(locale, path, bindings)
        end
      end

      unquote(translations)

      def do_t(_locale, _path, _bindings), do: {:error, :no_translation}

      def t!(locale, path, bindings \\ []) do
        case t(locale, path, bindings) do
          {:ok, translation} ->
            translation

          {:error, :no_translation} ->
            raise %NoTranslationError{message: "#{locale}: #{path}"}
        end
      end

      def locales do
        unquote(langs)
      end
    end
  end

  defp deftranslations(locale, current_path, translations) do
    for {key, val} <- translations do
      path = append_path(current_path, key)

      if Keyword.keyword?(val) do
        deftranslations(locale, path, val)
      else
        quote do
          def do_t(unquote(locale), unquote(path), bindings) do
            {:ok, unquote(interpolate(val, :bindings))}
          end
        end
      end
    end
  end

  # sobelow_skip ["DOS.StringToAtom"]
  defp interpolate(string, var) do
    @interpol_rgx
    |> Regex.split(string, on: [:head, :tail])
    |> Enum.reduce("", fn
      <<"%{" <> rest>>, acc ->
        key = String.to_atom(String.trim_trailing(rest, "}"))
        bindings = Macro.var(var, __MODULE__)

        quote do
          unquote(acc) <> to_string(Keyword.fetch!(unquote(bindings), unquote(key)))
        end

      segment, acc ->
        quote do: unquote(acc) <> unquote(unescape(segment))
    end)
  end

  defp append_path("", next), do: to_string(next)
  defp append_path(current, next), do: "#{current}.#{next}"

  defp unescape(segment) do
    Regex.replace(@escaped_interpol_rgx, segment, @simple_interpol)
  end
end
