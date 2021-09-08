defmodule VocabularyTest do
  use ExUnit.Case

  defmodule Ru.Cldr do
    use Cldr,
      providers: [],
      default_locale: "en",
      locales: ["ru", "en"]
  end

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

    locale(
      "ru",
      simple: "простое",
      interpolate: "интерполяция %{value}"
    )
  end

  defmodule I18n.FailingPluralization do
    use Linguist.Vocabulary
    locale(
      "ru",
      countable: [
        one: "%{count} элемент",
        few: "%{count} элемента",
        many: "%{count} элементов",
        other: "%{count} элементов"
      ]
    )
  end

  defmodule I18n.ValidPluralization1 do
    use Linguist.Vocabulary, cldr: Ru.Cldr

    locale(
      "ru",
      countable: [
        one: "%{count} элемент",
        few: "%{count} элемента",
        many: "%{count} элементов",
        other: "%{count} элементов"
      ]
    )
  end

  defmodule I18n.ValidPluralization2 do
    use Linguist.Vocabulary

    @cldr Ru.Cldr

    locale(
      "ru",
      countable: [
        one: "%{count} элемент",
        few: "%{count} элемента",
        many: "%{count} элементов",
        other: "%{count} элементов"
      ]
    )
  end

  test "it returns locales" do
    assert ["ru", "fr", "en", "es"] == I18n.locales()
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

  test "it compiles all locales" do
    assert I18n.t!("fr", "flash.notice.hello", first: "chris", last: "mccord") ==
             "salut chris mccord"

    assert I18n.t("fr", "flash.notice.hello", first: "chris", last: "mccord") ==
             {:ok, "salut chris mccord"}
  end

  test "it handles unknown locales" do
    assert I18n.t!("ru", "simple") == "простое"
    assert I18n.t("ru", "simple") == {:ok, "простое"}

    assert I18n.t!("ru", "interpolate", value: "значения") == "интерполяция значения"
    assert I18n.t("ru", "interpolate", value: "значения") == {:ok, "интерполяция значения"}
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

    test "t returns an error for unknown locale" do
      assert I18n.FailingPluralization.t("ru", "countable", count: 1) |> elem(0) == :error
    end

    test "t! throws an error for unknown locale" do
      assert_raise Cldr.UnknownLocaleError, fn ->
        assert I18n.FailingPluralization.t!("ru", "countable", count: 1)
      end
    end

    test "pluralizes unknown locale with custom Cldr backend" do
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 1) == "1 элемент"
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 2) == "2 элемента"
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 3) == "3 элемента"
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 4) == "4 элемента"
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 5) == "5 элементов"
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 6) == "6 элементов"
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 7) == "7 элементов"
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 8) == "8 элементов"
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 9) == "9 элементов"
      assert I18n.ValidPluralization1.t!("ru", "countable", count: 10) == "10 элементов"

      assert I18n.ValidPluralization2.t!("ru", "countable", count: 1) == "1 элемент"
      assert I18n.ValidPluralization2.t!("ru", "countable", count: 2) == "2 элемента"
      assert I18n.ValidPluralization2.t!("ru", "countable", count: 3) == "3 элемента"
      assert I18n.ValidPluralization2.t!("ru", "countable", count: 4) == "4 элемента"
      assert I18n.ValidPluralization2.t!("ru", "countable", count: 5) == "5 элементов"
      assert I18n.ValidPluralization2.t!("ru", "countable", count: 6) == "6 элементов"
      assert I18n.ValidPluralization2.t!("ru", "countable", count: 7) == "7 элементов"
      assert I18n.ValidPluralization2.t!("ru", "countable", count: 8) == "8 элементов"
      assert I18n.ValidPluralization2.t!("ru", "countable", count: 9) == "9 элементов"
      assert I18n.ValidPluralization2.t!("ru", "countable", count: 10) == "10 элементов"

      assert I18n.ValidPluralization1.t("ru", "countable", count: 1) == {:ok, "1 элемент"}
      assert I18n.ValidPluralization1.t("ru", "countable", count: 2) == {:ok, "2 элемента"}
      assert I18n.ValidPluralization1.t("ru", "countable", count: 3) == {:ok, "3 элемента"}
      assert I18n.ValidPluralization1.t("ru", "countable", count: 4) == {:ok, "4 элемента"}
      assert I18n.ValidPluralization1.t("ru", "countable", count: 5) == {:ok, "5 элементов"}
      assert I18n.ValidPluralization1.t("ru", "countable", count: 6) == {:ok, "6 элементов"}
      assert I18n.ValidPluralization1.t("ru", "countable", count: 7) == {:ok, "7 элементов"}
      assert I18n.ValidPluralization1.t("ru", "countable", count: 8) == {:ok, "8 элементов"}
      assert I18n.ValidPluralization1.t("ru", "countable", count: 9) == {:ok, "9 элементов"}
      assert I18n.ValidPluralization1.t("ru", "countable", count: 10) == {:ok, "10 элементов"}

      assert I18n.ValidPluralization2.t("ru", "countable", count: 1) == {:ok, "1 элемент"}
      assert I18n.ValidPluralization2.t("ru", "countable", count: 2) == {:ok, "2 элемента"}
      assert I18n.ValidPluralization2.t("ru", "countable", count: 3) == {:ok, "3 элемента"}
      assert I18n.ValidPluralization2.t("ru", "countable", count: 4) == {:ok, "4 элемента"}
      assert I18n.ValidPluralization2.t("ru", "countable", count: 5) == {:ok, "5 элементов"}
      assert I18n.ValidPluralization2.t("ru", "countable", count: 6) == {:ok, "6 элементов"}
      assert I18n.ValidPluralization2.t("ru", "countable", count: 7) == {:ok, "7 элементов"}
      assert I18n.ValidPluralization2.t("ru", "countable", count: 8) == {:ok, "8 элементов"}
      assert I18n.ValidPluralization2.t("ru", "countable", count: 9) == {:ok, "9 элементов"}
      assert I18n.ValidPluralization2.t("ru", "countable", count: 10) == {:ok, "10 элементов"}
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
