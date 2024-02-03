# Linguist
[![Test](https://github.com/change/linguist/actions/workflows/test.yml/badge.svg)](https://github.com/change/linguist/actions/workflows/test.yml)
[![version on Hex.pm](https://img.shields.io/hexpm/v/linguist)](https://hex.pm/packages/linguist)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/linguist)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/linguist)](https://hex.pm/packages/linguist)
[![License on Hex.pm](https://img.shields.io/hexpm/l/linguist)](https://github.com/change/linguist/blob/master/LICENSE)

> Linguist is a simple Elixir Internationalization library

## Usage

```elixir
defmodule I18n do
  use Linguist.Vocabulary

  locale "en", [
    flash: [
      notice: [
        hello: "hello %{first} %{last}",
        bye: "bye now, %{name}!"
      ]
    ],
    users: [
      title: "Users",
      profiles: [
        title: "Profiles",
      ]
    ]
  ]

  locale "fr", Path.join([__DIR__, "fr.exs"])

end

# fr.exs
[
  flash: [
    notice: [
      hello: "salut %{first} %{last}"
    ]
  ]
]

iex> I18n.t!("en", "flash.notice.hello", first: "chris", last: "mccord")
"hello chris mccord"

iex> I18n.t!("fr", "flash.notice.hello", first: "chris", last: "mccord")
"salut chris mccord"

iex> I18n.t!("en", "users.title")
"Users"
```

## Configuration

The key to use for pluralization is configurable, and should likely be an atom:

```elixir
config :linguist, pluralization_key: :count
```
will cause the system to pluralize based on the `count` parameter passed to the `t` function.
