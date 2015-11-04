defmodule PluralTest do
  use ExUnit.Case

  defmodule I18n do
    use Linguist.Vocabulary

    locale "en", Path.join([__DIR__, "en.exs"])
    locale "ja", Path.join([__DIR__, "ja.exs"])
  end

  test "it handles English plurals" do
    assert I18n.t!("en", "users.friends", count: 0) == "no friends"
    assert I18n.t!("en", "users.friends", count: 1) == "1 friend"
    assert I18n.t!("en", "users.friends", count: 2) == "2 friends"
  end

  test "it handles Japanese plurals" do
    assert I18n.t!("ja", "users.friends", count: 0) == "0人友達"
    assert I18n.t!("ja", "users.friends", count: 1) == "1人友達"
    assert I18n.t!("ja", "users.friends", count: 2) == "2人友達"
  end
end
