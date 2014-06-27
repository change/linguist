defmodule Linguist.Compiler do
  alias Linguist.Compiler

  defmacro __using__(options) do
    locales = Dict.fetch! options, :locales

    for {locale, source} <- locales do
      deftranslations(to_string(locale), "", source)
    end
  end

  def deftranslations(locale, current_path, translations) do
    for {key, val} <- translations do
      path = append_path(current_path, key)

      if Keyword.keyword?(val) do
        deftranslations(locale, path, val)
      else
        quote do
          def t(unquote(locale), unquote(path)) do
            t(unquote(locale), unquote(path), [])
          end
          def t(unquote(locale), unquote(path), bindings) do
            unquote(Compiler.interpolate(val, :bindings))
          end
        end
      end
    end
  end

  def interpolate(string, var) do
    Regex.split(~r/(%{[^}]+})/, string) |> Enum.reduce fn
      <<"%{" <> rest>>, acc ->
        key      = String.to_atom(String.rstrip(rest, ?}))
        bindings = Macro.var(var, __MODULE__)
        quote do
          unquote(acc) <> Dict.fetch!(unquote(bindings), unquote(key))
        end
      segment, acc -> quote do: (unquote(acc) <> unquote(segment))
    end
  end

  defp append_path("", next), do: to_string(next)
  defp append_path(current, next), do: "#{current}.#{next}"
end

