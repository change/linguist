defmodule Linguist.Vocabulary do
  alias Linguist.Compiler

  @moduledoc """
  Defines lookup functions for translation locales, with binding interpolation.

  `use Linguist.Vocabulary` in a module, then add locales with the `locale/2`
  macro. Each locale is given a name, and either a keyword list of
  translations, or the path to an `.exs` file that evaluates to a keyword
  list, or to a `.yml` or `.yaml` file.

  For example:

      defmodule I18n do
        use Linguist.Vocabulary

        locale "en", [
          flash: [
            notice: [
              hello: "hello %{first} %{last}"
            ]
          ],
          users: [
            title: "Users"
          ]
        ]

        locale "fr", Path.join([__DIR__, "fr.exs"])
      end

  The translations are compiled into `t/3`, `t!/3` and `locales/0` functions
  on the module:

      I18n.t("en", "flash.notice.hello", first: "Alex", last: "Smith")
      #=> {:ok, "hello Alex Smith"}

      I18n.t!("en", "users.title")
      #=> "Users"

      I18n.locales()
      #=> ["fr", "en"]
  """

  @doc """
  Sets up the current module to add locales with `locale/2`.

  The locales are compiled into functions when the module is compiled, by
  `__before_compile__/1`.
  """
  defmacro __using__(_options) do
    quote do
      Module.register_attribute(__MODULE__, :locales, accumulate: true, persist: false)
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  @doc """
  Compiles the locales registered with `locale/2` into the `t/3`, `t!/3` and
  `locales/0` functions of the current module.

  Invoked by the compiler through `@before_compile`, set by `use Linguist.Vocabulary`.
  """
  defmacro __before_compile__(env) do
    Compiler.compile(Module.get_attribute(env.module, :locales))
  end

  @doc """
  Adds a locale to the current module.

  * name - The String name of the locale, e.g. "en", "fr"
  * source - One of:
    1. A keyword list of translations
    2. The String path to an `.exs` file that evaluates to a keyword list of translations
    3. The String path to a `.yml` or `.yaml` file of translations

  ## Examples

      locale "en", [
        flash: [
          notice: [
            hello: "hello %{first} %{last}"
          ]
        ]
      ]

      locale "fr", Path.join([__DIR__, "fr.exs"])

      locale "es", Path.join([__DIR__, "es.yml"])
  """
  defmacro locale(name, source) do
    quote bind_quoted: [name: name, source: source] do
      loaded_source =
        cond do
          is_binary(source) && String.ends_with?(source, [".yml", ".yaml"]) ->
            Linguist.Vocabulary._load_yaml_file(source)

          is_binary(source) ->
            @external_resource source
            source
            |> Code.eval_file()
            |> elem(0)

          true ->
            source
        end

      name = name |> to_string()

      @locales {name, loaded_source}
    end
  end

  @doc """
  Loads a YAML file into a keyword list of translations.

  Used internally by the `locale/2` macro, which should be used to add a YAML
  file of translations.
  """
  @spec _load_yaml_file(Path.t()) :: keyword()
  def _load_yaml_file(source) do
    {:ok, [result]} = YamlElixir.read_all_from_file(source)

    result
    |> Enum.reduce([], &Linguist.Vocabulary._yaml_reducer/2)
  end

  @doc """
  Recursive function used internally for loading YAML files.

  Not intended for external use.
  """
  @spec _yaml_reducer({String.t(), term()}, keyword()) :: keyword()
  # sobelow_skip ["DOS.StringToAtom"]
  def _yaml_reducer({key, value}, acc) when is_binary(value) do
    # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
    [{String.to_atom(key), value} | acc]
  end

  # sobelow_skip ["DOS.StringToAtom"]
  def _yaml_reducer({key, value}, acc) do
    # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
    [{String.to_atom(key), Enum.reduce(value, [], &Linguist.Vocabulary._yaml_reducer/2)} | acc]
  end
end
