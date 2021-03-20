use Mix.Config

config :ex_cldr, json_library: Jason

if Mix.env() == :test do
  config :linguist, Linguist.Cldr, locales: ["fr", "en", "es"]

  config :linguist, vocabulary_backend: (System.get_env("SCHEMA_PROVIDER") || "ets") |> String.to_existing_atom()
end
