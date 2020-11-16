# Linguist
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

### Pluralization key

The key to use for pluralization is configurable, and should likely be an atom:

```elixir
# default
config :linguist, pluralization_key: :count
```

Will cause the system to pluralize based on the `count` parameter passed to the `t` function.

But also you should add proper locale to Cldr backend.

There are multiple ways to perform that:

1. By default, linguist creates its own Cldr backend module `Linguist.Cldr`. It handles only `en` locale plurals but you can add more locales:

```elixir
config :linguist, Linguist.Cldr, locales: ["fr", "es"]
```

But this way is not recommended because it is not flexible.


2. You can pass your own Cldr backend module within application config:

```elixir
config :linguist, cldr: MyApp.Cldr
```

3. If you've using `Linguist.Vocabulary`, you can pass own Cldr module name explicitly in your I18n module:

```elixir
defmodule I18n do
  use Linguist.Vocabulary, cldr: MyApp.Cldr

  ...
end
```

or like that:

```elixir
defmodule I18n do
  use Linguist.Vocabulary

  @cldr MyApp.Cldr

end
```

4. If you've using `Linguist.MemoizedVocabulary`, you can set up own Cldr module name:

```elixir
Linguist.MemorizedVocabulary.cldr(MyApp.Cldr)
```
