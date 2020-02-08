Code.ensure_loaded?(Hex) and Hex.start()

defmodule Linguist.Mixfile do
  use Mix.Project

  def project do
    [
      app: :linguist,
      version: "0.2.1",
      compilers: Mix.compilers() ++ [:cldr],
      elixir: "~> 1.9.1",
      deps: deps(),
      package: [
        contributors: ["Will Barrett, Chris McCord"],
        licenses: ["MIT"],
        links: %{github: "https://github.com/change/linguist"}
      ],
      description: """
      Elixir Internationalization library, extended to support translation files in the rails-i18n format
      """
    ]
  end

  def application do
    [applications: [:yaml_elixir]]
  end

  defp deps do
    [
      {:ex_cldr, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:yaml_elixir, "~> 2.0"},
      {:credo, "~> 0.9.0", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.10", only: :dev, runtime: false}
    ]
  end
end
