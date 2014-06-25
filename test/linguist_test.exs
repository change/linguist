defmodule LinguistTest do
  use ExUnit.Case

  defmodule I18n do
    use Linguist.Compiler, locales: [en: [
      foo: "bar",
      flash: [
        notice: [
          alert: "Alert!",
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

  test "it handles translations at rool level" do
    assert I18n.t("en", "foo") == "bar"
  end

  test "it handles nested translations" do
    assert I18n.t("en", "flash.notice.alert") == "Alert!"
  end

  test "it recursively walks translations tree" do
    assert I18n.t("en", "users.title") == "Users"
    assert I18n.t("en", "users.profiles.title") == "Profiles"
  end

  test "it iterpolates bindings" do
    assert I18n.t("en", "flash.notice.hello", first: "chris", last: "mccord") == "hello chris mccord"
    assert I18n.t("en", "flash.notice.bye", name: "chris") == "bye now, chris!"
  end

  test "raises KeyError when bindings not provided" do
    assert_raise KeyError, fn ->
      I18n.t("en", "flash.notice.hello", first: "chris")
    end
  end
end

