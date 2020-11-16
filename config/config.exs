use Mix.Config

config :linguist,
  pluralization_key: :count,
  cldr: Linguist.Cldr

config :ex_cldr, json_library: Jason

if Mix.env() == :test do
  config :linguist, Linguist.Cldr, locales: ["fr", "en", "es"]
end
