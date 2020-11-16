Code.ensure_loaded?(Hex) and Hex.start()

defmodule Linguist.Mixfile do
  use Mix.Project

  @description """
  Elixir Internationalization library, extended to support translation files in the rails-i18n format.
  """

  @repo_url "https://github.com/change/linguist"

  @version "0.3.1"

  def project do
    [
      app: :linguist,
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),

      # Hex
      package: package(),
      description: @description,

      # Docs
      name: "Linguist",
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: @repo_url
      ]
    ]
  end

  def application do
    [applications: [:yaml_elixir, :ex_cldr]]
  end

  def package do
    [
      maintainers: ["John Mertens", "Justin Almeida"],
      licenses: ["MIT"],
      links: %{github: @repo_url}
    ]
  end

  defp deps do
    [
      {:ex_cldr, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:yaml_elixir, "~> 2.0"},

      {:ex_doc, "~> 0.21.3", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.9.0", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.10", only: :dev, runtime: false}
    ]
  end
end
