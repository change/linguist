# Linguist
> Linguist is a simple Elixir Internationalization library


## Usage

```elixir
  defmodule Translations do
    use Linguist.Compiler, locales: [
      en: [
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
      fr: [
        flash: [
          notice: [
            hello: "salut %{first} %{last}"
          ]
       ],
    ]
  end

iex> Translations.t("en", "flash.notice.hello", first: "chris", last: "mccord")
"hello chris mccord"

iex> Translations.t("fr", "flash.notice.hello", first: "chris", last: "mccord")
"salut chris mccord"

iex> Translations.t("en", "flash.users.title")
"Users"
```

