import Config

config :linguist, pluralization_key: :count

if Mix.env() == :test do
  config :linguist, Linguist.Cldr, locales: ["fr", "en", "es"]
end
