use Mix.Config

config :linguist, pluralization_key: :count

config :ex_cldr, json_library: Jason, default_backend: Linguist.Cldr

config :linguist, Linguist.Cldr,
  default_locale: "en",
  data_dir: "./priv/linguist/cldr_data",
  locales: ["fr", "en", "es"]
