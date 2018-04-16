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

The key to use for pluralization is configurable, and should likely be an atom:

```
config :linguist, pluralization_key: :count
```
will cause the system to pluralize based on the `count` parameter passed to the `t` function.
