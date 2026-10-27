defmodule Linguist.Cldr do
  @moduledoc """
  The ex_cldr backend that provides the plural rules for each locale.

  Add each locale used for pluralization, other than "en", to its config:

      config :linguist, Linguist.Cldr, locales: ["en", "es", "fr"]
  """
  use Cldr,
    otp_app: :linguist,
    providers: [],
    data_dir: "./priv/cldr",
    default_locale: "en"
end
