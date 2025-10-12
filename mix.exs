Code.ensure_loaded?(Hex) and Hex.start()

defmodule Linguist.MixProject do
  @moduledoc false
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :linguist,
      version: @version,
      elixir: "~> 1.14",
      deps: deps(),
      package: package(),
      description: description(),
      name: "Linguist",
      source_url: source_url(),
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: source_url()
      ]
    ]
  end

  def application do
    []
  end

  defp package do
    [
      maintainers: ["Change.org"],
      licenses: ["MIT"],
      links: %{github: source_url()}
    ]
  end

  defp source_url do
    "https://github.com/change/linguist"
  end

  defp description do
    "Elixir Internationalization library, extended to support translation files in the rails-i18n format."
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_cldr, "~> 2.37"},
      {:ex_doc, "~> 0.38.4", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.0"},
      {:sobelow, "~> 0.10", only: :dev, runtime: false},
      {:yaml_elixir, "~> 2.0"}
    ]
  end
end
