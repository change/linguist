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
      ]]
  end

iex> Translations.t("en", "flash.notice.hello", first: "chris", last: "mccord")
"hello chris mccord"

iex> Translations.t("en", "flash.users.title")
"Users"
```

