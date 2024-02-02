import Config

config :linguist, pluralization_key: :count

config :ex_cldr, json_library: Jason

if Mix.env() == :test do
  config :linguist, Linguist.Cldr, locales: ["fr", "en", "es"]
end
