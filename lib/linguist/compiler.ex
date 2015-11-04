defmodule Linguist.Compiler do
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

    def t("en", "hello", bindings), do: "Hello " <> Dict.fetch!(bindings, :name)
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

  @interpol_rgx  ~r/
                   (?<head>)
                   (?<!%) %{.+?}
                   (?<tail>)
                   /x

  @escaped_interpol_rgx ~r/%%{/
  @simple_interpol "%{"

  def compile(translations) do
    langs = Dict.keys translations
    translations =
      for {locale, source} <- translations do
        deftranslations(to_string(locale), "", source)
      end

    quote do
      def t(locale, path, binding \\ [])
      unquote(translations)
      def t(_locale, _path, _bindings), do: {:error, :no_translation}
      def t!(locale, path, bindings \\ []) do
        case t(locale, path, bindings) do
          {:ok, translation} -> translation
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
        if val[:_plural] do
          quote do
            def t(unquote(locale), unquote(path), bindings) do
              cond do
                bindings[:count] == 0 ->
                  {:ok, unquote(interpolate(val[:zero] || val[:other], :bindings))}
                bindings[:count] == 1 ->
                  {:ok, unquote(interpolate(val[:one] || val[:other], :bindings))}
                bindings[:count] == 2 ->
                  {:ok, unquote(interpolate(val[:two] || val[:other], :bindings))}
                true ->
                  {:ok, unquote(interpolate(val[:other], :bindings))}
              end
            end
          end
        else
          deftranslations(locale, path, val)
        end
      else
        quote do
          def t(unquote(locale), unquote(path), bindings) do
            {:ok, unquote(interpolate(val, :bindings))}
          end
        end
      end
    end
  end

  defp interpolate(string, var) do
    @interpol_rgx
      |> Regex.split(string, on: [:head, :tail])
      |> Enum.reduce( "", fn
      <<"%{" <> rest>>, acc ->
        key      = String.to_atom(String.rstrip(rest, ?}))
        bindings = Macro.var(var, __MODULE__)
        quote do
          unquote(acc) <> to_string(Dict.fetch!(unquote(bindings), unquote(key)))
        end
      segment, acc -> quote do: (unquote(acc) <> unquote(unescape(segment)))
    end )
  end

  defp append_path("", next), do: to_string(next)
  defp append_path(current, next), do: "#{current}.#{next}"

  defp unescape(segment) do
      Regex.replace @escaped_interpol_rgx, segment, @simple_interpol
  end
end
