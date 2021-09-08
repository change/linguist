defmodule MemorizedVocabularyTest do
  use ExUnit.Case

  defmodule Ru.Cldr do
    use Cldr,
      providers: [],
      default_locale: "en",
      locales: ["ru", "en"]
  end

  setup do
    Linguist.MemorizedVocabulary.locale("es", Path.join([__DIR__, "es.yml"]))
    Linguist.MemorizedVocabulary.locale("fr-FR", Path.join([__DIR__, "fr-FR.yml"]))
    Linguist.MemorizedVocabulary.locale("ru", Path.join([__DIR__, "ru.yml"]))
    :ok
  end

  test "locales() returns locales" do
    assert ["ru", "fr-FR", "es"] == Linguist.MemorizedVocabulary.locales()
  end

  test "t returns a translation" do
    assert {:ok, "bar"} == Linguist.MemorizedVocabulary.t("es", "foo")
  end

  test "t interpolates values" do
    assert {:ok, "hola Michael Westin"} ==
             Linguist.MemorizedVocabulary.t(
               "es",
               "flash.notice.hello",
               first: "Michael",
               last: "Westin"
             )
  end

  test "it handles unknown locales" do
    assert Linguist.MemorizedVocabulary.t!("ru", "simple") == "простое"
    assert Linguist.MemorizedVocabulary.t("ru", "simple") == {:ok, "простое"}

    assert Linguist.MemorizedVocabulary.t!("ru", "interpolate", value: "значения") == "интерполяция значения"
    assert Linguist.MemorizedVocabulary.t("ru", "interpolate", value: "значения") == {:ok, "интерполяция значения"}
  end

  test "t returns {:error, :no_translation} when translation is missing" do
    assert Linguist.MemorizedVocabulary.t("es", "flash.not_exists") == {:error, :no_translation}
  end

  test "t! raises NoTranslationError when translation is missing" do
    assert_raise Linguist.NoTranslationError, fn ->
      Linguist.MemorizedVocabulary.t!("es", "flash.not_exists")
    end
  end

  test "t pluralizes" do
    assert {:ok, "2 manzanas"} == Linguist.MemorizedVocabulary.t("es", "apple", count: 2)
  end

  test "t will normalize a locale to format ll-LL" do
    assert {:ok, "Ennui"} == Linguist.MemorizedVocabulary.t("FR-fr", "flash.notice.alert")
  end

  test "t will raise a LocaleError if a malformed locale is passed in" do
    assert_raise Linguist.LocaleError, fn ->
      Linguist.MemorizedVocabulary.t("es-es-es", "flash.notice.alert")
    end

    assert_raise Linguist.LocaleError, fn ->
      Linguist.MemorizedVocabulary.t(nil, "flash.notice.alert")
    end
  end

  test "t pluralized returns an error for unknown locale" do
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 1) |> elem(0) == :error
  end

  test "t! pluralized throws an error for unknown locale" do
    assert_raise Cldr.UnknownLocaleError, fn ->
      assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 1)
    end
  end

  test "t! pluralizes unknown locale with custom Cldr backend" do
    :ets.delete(:translations_registry, "memorized_vocabulary.cldr")

    Linguist.MemorizedVocabulary.cldr(Ru.Cldr)

    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 1) == "1 элемент"
    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 2) == "2 элемента"
    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 3) == "3 элемента"
    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 4) == "4 элемента"
    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 5) == "5 элементов"
    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 6) == "6 элементов"
    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 7) == "7 элементов"
    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 8) == "8 элементов"
    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 9) == "9 элементов"
    assert Linguist.MemorizedVocabulary.t!("ru", "countable", count: 10) == "10 элементов"
    :ets.delete(:translations_registry, "memorized_vocabulary.cldr")
  end

  test "t pluralizes unknown locale with custom Cldr backend" do
    :ets.delete(:translations_registry, "memorized_vocabulary.cldr")

    Linguist.MemorizedVocabulary.cldr(Ru.Cldr)

    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 1) == {:ok, "1 элемент"}
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 2) == {:ok, "2 элемента"}
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 3) == {:ok, "3 элемента"}
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 4) == {:ok, "4 элемента"}
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 5) == {:ok, "5 элементов"}
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 6) == {:ok, "6 элементов"}
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 7) == {:ok, "7 элементов"}
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 8) == {:ok, "8 элементов"}
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 9) == {:ok, "9 элементов"}
    assert Linguist.MemorizedVocabulary.t("ru", "countable", count: 10) == {:ok, "10 элементов"}
    :ets.delete(:translations_registry, "memorized_vocabulary.cldr")
  end
end
