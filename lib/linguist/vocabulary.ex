defmodule Linguist.Vocabulary do
  alias Linguist.Compiler

  @moduledoc """
  Defines lookup functions for given translation locales, binding interopolation

  Locales are defined with the `locale/2` macro, accepting a locale name and
  either keyword list of translations or String path to evaluate for
  translations list.

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

  this module will compile this down to these functions :

  def t("en", "flash.notice.hello", bindings \\ []), do: # ...
  def t("en", "users.title", bindings \\ []), do: # ...
  def t("fr", "flash.notice.hello", bindings \\ []), do: # ...
  """

  @doc """
  Compiles all the translations and inject the functions created in the current module.
  """
  defmacro __using__(options \\ []) do
    cldr = Keyword.get(options, :cldr, Application.get_env(:linguist, :cldr))
    quote do
      Module.register_attribute(__MODULE__, :locales, accumulate: true, persist: false)

      Module.register_attribute(__MODULE__, :cldr, accumulate: false, persist: false)
      Module.put_attribute(__MODULE__, :cldr, unquote(cldr))

      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    Compiler.compile(Module.get_attribute(env.module, :locales), Module.get_attribute(env.module, :cldr))
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
      loaded_source =
        cond do
          is_binary(source) && String.ends_with?(source, [".yml", ".yaml"]) ->
            Linguist.Vocabulary._load_yaml_file(source)

          is_binary(source) ->
            @external_resource source
            source |> Code.eval_file() |> elem(0)

          true ->
            source
        end

      name = name |> to_string()

      @locales {name, loaded_source}
    end
  end

  @doc """
  Function used internally to load a yaml file. Please use
  the `locale` macro with a path to a yaml file - this function
  will not work as expected if called directly.
  """
  def _load_yaml_file(source) do
    {:ok, [result]} = YamlElixir.read_all_from_file(source)

    result
    |> Enum.reduce([], &Linguist.Vocabulary._yaml_reducer/2)
  end

  @doc """
  Recursive function used internally for loading yaml files.
  Not intended for external use
  """
  # sobelow_skip ["DOS.StringToAtom"]
  def _yaml_reducer({key, value}, acc) when is_binary(value) do
    [{String.to_atom(key), value} | acc]
  end

  # sobelow_skip ["DOS.StringToAtom"]
  def _yaml_reducer({key, value}, acc) do
    [{String.to_atom(key), Enum.reduce(value, [], &Linguist.Vocabulary._yaml_reducer/2)} | acc]
  end
end
