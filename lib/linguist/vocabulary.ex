defmodule Linguist.Vocabulary do
  alias Linguist.Compiler

  @moduledoc """
  Defines lookup functions for given translation locales, binding interopolation

  Locales are defined with the `locale/2` macro, accepting a locale name and
  either keyword list of translations or String path to evaluate for
  translations list.

  For example, given the following translations :

  ```elixir
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
  defmacro __using__(_options) do
    quote do
      Module.register_attribute(__MODULE__, :locales, accumulate: true, persist: false)
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    Compiler.compile(Module.get_attribute(env.module, :locales))
  end

  @doc """
  Embeds locales from provided source

  * name - The String name of the locale, ie "en", "fr"
  * source -
    1. The String file path to eval that returns a keyword list of translactions
    2. The Keyword List of translations

  Examples

  locale "en", [
    flash: [
      notice: [
        hello: "hello %{first} %{last}",
      ]
    ]
  ]
  locale "fr", Path.join([__DIR__, "fr.exs"])
  """
  defmacro locale(name, source) do
    quote bind_quoted: [name: name, source: source] do
      if is_binary(source) do
        source = Code.eval_file(source) |> elem(0)
      end
      @locales {name, source}
    end
  end

end

