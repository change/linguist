defmodule VocabularyTest do
  use ExUnit.Case

  defmodule I18n do
    use Linguist.Vocabulary
    locale("es", Path.join([__DIR__, "es.yml"]))

    locale("en", Path.join([__DIR__, "en.exs"]))

    locale(
      "fr",
      flash: [
        notice: [
          hello: "salut %{first} %{last}"
        ],
        interpolation_at_beginning: "%{name} at beginning"
      ],
      apple: [
        one: "%{count} Pomme",
        other: "%{count} pommes"
      ]
    )
  end

  test "it returns locales" do
    assert ["fr", "en", "es"] == I18n.locales()
  end

  test "it handles both string and atom locales" do
    assert I18n.t!("en", "foo") == I18n.t!(:en, "foo")
    assert I18n.t("en", "foo") == I18n.t(:en, "foo")
  end

  test "it handles translations at rool level" do
    assert I18n.t!("en", "foo") == "bar"
    assert I18n.t("en", "foo") == {:ok, "bar"}
  end

  test "it handles nested translations" do
    assert I18n.t!("en", "flash.notice.alert") == "Alert!"
    assert I18n.t("en", "flash.notice.alert") == {:ok, "Alert!"}
  end

  test "it recursively walks translations tree" do
    assert I18n.t!("en", "users.title") == "Users"
    assert I18n.t("en", "users.title") == {:ok, "Users"}
    assert I18n.t!("en", "users.profiles.title") == "Profiles"
    assert I18n.t("en", "users.profiles.title") == {:ok, "Profiles"}
  end

  test "it interpolates bindings" do
    assert I18n.t!("en", "flash.notice.hello", first: "chris", last: "mccord") ==
             "hello chris mccord"

    assert I18n.t("en", "flash.notice.hello", first: "chris", last: "mccord") ==
             {:ok, "hello chris mccord"}

    assert I18n.t!("en", "flash.notice.bye", name: "chris") == "bye now, chris!"
    assert I18n.t("en", "flash.notice.bye", name: "chris") == {:ok, "bye now, chris!"}
  end

  test "t raises KeyError when bindings not provided" do
    assert_raise KeyError, fn ->
      I18n.t("en", "flash.notice.hello", first: "chris")
    end
  end

  test "t! raises KeyError when bindings not provided" do
    assert_raise KeyError, fn ->
      I18n.t!("en", "flash.notice.hello", first: "chris")
    end
  end

  test "it compiles all locales" do
    assert I18n.t!("fr", "flash.notice.hello", first: "chris", last: "mccord") ==
             "salut chris mccord"

    assert I18n.t("fr", "flash.notice.hello", first: "chris", last: "mccord") ==
             {:ok, "salut chris mccord"}
  end

  test "t! raises NoTranslationError when translation is missing" do
    assert_raise Linguist.NoTranslationError, fn ->
      I18n.t!("en", "flash.not_exists")
    end
  end

  test "t returns {:error, :no_translation} when translation is missing" do
    assert I18n.t("en", "flash.not_exists") == {:error, :no_translation}
  end

  test "converts interpolation values to string" do
    assert I18n.t!("fr", "flash.notice.hello", first: 123, last: "mccord") == "salut 123 mccord"
  end

  test "interpolations can exist as the first segment of the translation" do
    assert I18n.t!("fr", "flash.interpolation_at_beginning", name: "chris") ==
             "chris at beginning"
  end

  describe "pluralizations" do
    test "pluralizes English correctly" do
      assert I18n.t!("en", "apple", count: 1) == "1 apple"
      assert I18n.t!("en", "apple", count: 2) == "2 apples"
    end

    test "pluralizes Spanish correctly" do
      assert I18n.t!("es", "apple", count: 1) == "1 manzana"
      assert I18n.t!("es", "apple", count: 2) == "2 manzanas"
    end

    test "throws an error when a pluralized string is not given a count" do
      assert_raise Linguist.NoTranslationError, fn ->
        I18n.t!("en", "apple")
      end
    end
  end

  test "translations in yaml files are loaded successfully" do
    assert I18n.t!("es", "flash.notice.hello", first: 123, last: "mccord") == "hola 123 mccord"
  end
end
