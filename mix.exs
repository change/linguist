Code.ensure_loaded?(Hex) and Hex.start

defmodule Linguist.Mixfile do
  use Mix.Project

  def project do
    [
      app: :linguist,
      version: "0.1.5",
      elixir: "~> 1.6",
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
    [applications: []]
  end

  defp deps do
    [
      {:ex_cldr, "~> 1.5"},
      {:jason, "~> 1.0"}
    ]
  end
end
