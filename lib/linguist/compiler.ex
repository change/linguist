defmodule Linguist.Compiler do
  alias Linguist.Compiler

  @moduledoc """
  This module compiles the given translations in a method `t` of the form `t(locale, path, bindings)`.

  For example, given the following translations :

  ```elixir
  [
    en: [
      flash: [
        notice: [
          hello: "hello %{first} %{last}",
        ]
      ],
      users: [
        title: "Users",
      ]
    ],
    fr: [
      flash: [
        notice: [
          hello: "salut %{first} %{last}"
        ]
      ]
    ]
  ]
  ```

  this module will compile this down to these methods :

  ```elixir
  def t("en", "flash.notice.hello", bindings \\ []), do: # ...
  def t("en", "users.title", bindings \\ []), do: # ...
  def t("fr", "flash.notice.hello", bindings \\ []), do: # ...
  ```
  """

  @doc """
  Compiles all the translations and inject the methods created in the current module.
  """
  defmacro __using__(options) do
    locales = Dict.fetch! options, :locales

    translations =
      for {locale, source} <- locales do
        deftranslations(to_string(locale), "", source)
      end

    quote do
      def t(locale, path, binding \\ [])
      unquote(translations)
    end
  end

  @doc """
  Recursively define the `t` methods.
  """
  def deftranslations(locale, current_path, translations) do
    for {key, val} <- translations do
      path = append_path(current_path, key)

      if Keyword.keyword?(val) do
        deftranslations(locale, path, val)
      else
        quote do
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

