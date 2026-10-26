# Linguist

[![Test](https://github.com/change/linguist/actions/workflows/test.yml/badge.svg)](https://github.com/change/linguist/actions/workflows/test.yml)
[![Version on Hex.pm](https://img.shields.io/hexpm/v/linguist.svg)](https://hex.pm/packages/linguist)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/linguist)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/linguist.svg)](https://hex.pm/packages/linguist)
[![License](https://img.shields.io/hexpm/l/linguist.svg)](https://github.com/change/linguist/blob/main/LICENSE)
[![Latest commit](https://img.shields.io/github/last-commit/change/linguist.svg)](https://github.com/change/linguist/commits/main)
![GitHub top language](https://img.shields.io/github/languages/top/change/linguist)

Linguist is a simple Elixir internationalization library.

## Installation

Add `:linguist` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:linguist, "~> 0.6"}
  ]
end
```

Update your dependencies:

```bash
$ mix deps.get
```

## Usage

Define a module that uses `Linguist.Vocabulary`, and add each locale with the
`locale/2` macro. Translations can be given as a keyword list, or as a path to
an `.exs` file that evaluates to a keyword list, or to a `.yml`/`.yaml` file.
They are compiled into functions on the module.

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
        title: "Profiles"
      ]
    ]
  ]

  locale "fr", Path.join([__DIR__, "fr.exs"])
  locale "es", Path.join([__DIR__, "es.yml"])
end
```

`fr.exs`:

```elixir
[
  flash: [
    notice: [
      hello: "salut %{first} %{last}"
    ]
  ]
]
```

`es.yml`:

```yaml
flash:
  notice:
    hello: "hola %{first} %{last}"
```

Look up translations by locale and dot-separated path, passing any
interpolation bindings:

```elixir
iex> I18n.t!("en", "flash.notice.hello", first: "chris", last: "mccord")
"hello chris mccord"

iex> I18n.t!("fr", "flash.notice.hello", first: "chris", last: "mccord")
"salut chris mccord"

iex> I18n.t("es", "flash.notice.hello", first: "Alex", last: "Smith")
{:ok, "hola Alex Smith"}

iex> I18n.t("en", "users.missing")
{:error, :no_translation}

iex> I18n.locales()
["es", "fr", "en"]
```

`t/3` returns `{:ok, translation}` or `{:error, :no_translation}`, and `t!/3`
returns the translation or raises `Linguist.NoTranslationError`. Both raise
`KeyError` if a binding used by the translation is missing. Use `%%{` to
include a literal `%{` in a translation.

### Loading YAML files at runtime

`Linguist.MemorizedVocabulary` loads YAML files at runtime rather than at
compile time, and stores the translations in an ETS table:

```elixir
iex> Linguist.MemorizedVocabulary.locale("es", "priv/locales/es.yml")
true

iex> Linguist.MemorizedVocabulary.t("es", "flash.notice.hello", first: "Alex", last: "Smith")
{:ok, "hola Alex Smith"}
```

The ETS table is owned by the process that loads the first locale, so load
all the locales from a long-lived process, such as during application start.
Locale names are normalized, so `"ES"` is looked up as `"es"`, and `"fr-fr"`
as `"fr-FR"`.

## Pluralization

When the bindings include the pluralization key, the translation is looked up
under the plural category for that number, following the CLDR plural rules
for the locale, such as `one` or `other`:

```elixir
locale "en", [
  apple: [
    one: "%{count} apple",
    other: "%{count} apples"
  ]
]
```

```elixir
iex> I18n.t!("en", "apple", count: 1)
"1 apple"

iex> I18n.t!("en", "apple", count: 2)
"2 apples"
```

## Configuration

The pluralization key is required, and should be an atom:

```elixir
config :linguist, pluralization_key: :count
```

With this config, translations are pluralized based on the `count` binding
passed to `t/3` or `t!/3`.

Pluralization uses [ex_cldr](https://hex.pm/packages/ex_cldr), which only
knows the `en` locale by default. Add every other locale you pluralize to the
`Linguist.Cldr` backend:

```elixir
config :linguist, Linguist.Cldr, locales: ["en", "es", "fr"]
```
