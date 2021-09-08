defmodule MemorizedVocabularyTest do
  use ExUnit.Case

  setup do
    Linguist.MemorizedVocabulary.locale(:es, Path.join([__DIR__, "es.yml"]))
    Linguist.MemorizedVocabulary.locale("fr-FR", Path.join([__DIR__, "fr-FR.yml"]))
    :ok
  end

  test "locales() returns locales" do
    assert ["fr-FR", "es"] == Linguist.MemorizedVocabulary.locales()
  end

  test "t returns a translation" do
    assert {:ok, "bar"} == Linguist.MemorizedVocabulary.t("es", "foo")
    assert {:ok, "bar"} == Linguist.MemorizedVocabulary.t(:es, "foo")
  end

  test "t interpolates values" do
    assert {:ok, "hola Michael Westin"} ==
             Linguist.MemorizedVocabulary.t(
               "es",
               "flash.notice.hello",
               first: "Michael",
               last: "Westin"
             )
    assert {:ok, "hola Michael Westin"} ==
            Linguist.MemorizedVocabulary.t(
              :es,
              "flash.notice.hello",
              first: "Michael",
              last: "Westin"
            )
  end

  test "t returns {:error, :no_translation} when translation is missing" do
    assert Linguist.MemorizedVocabulary.t("es", "flash.not_exists") == {:error, :no_translation}
    assert Linguist.MemorizedVocabulary.t(:es, "flash.not_exists") == {:error, :no_translation}
  end

  test "t! raises NoTranslationError when translation is missing" do
    assert_raise Linguist.NoTranslationError, fn ->
      Linguist.MemorizedVocabulary.t!("es", "flash.not_exists")
    end
    assert_raise Linguist.NoTranslationError, fn ->
      Linguist.MemorizedVocabulary.t!(:es, "flash.not_exists")
    end
  end

  test "t pluralizes" do
    assert {:ok, "2 manzanas"} == Linguist.MemorizedVocabulary.t("es", "apple", count: 2)
    assert {:ok, "2 manzanas"} == Linguist.MemorizedVocabulary.t(:es, "apple", count: 2)
  end

  test "t will normalize a locale to format ll-LL" do
    assert {:ok, "Ennui"} == Linguist.MemorizedVocabulary.t("FR-fr", "flash.notice.alert")
    assert {:ok, "Ennui"} == Linguist.MemorizedVocabulary.t(:"FR-fr", "flash.notice.alert")
  end

  test "t will raise a LocaleError if a malformed locale is passed in" do
    assert_raise Linguist.LocaleError, fn ->
      Linguist.MemorizedVocabulary.locale("es-es-es", Path.join([__DIR__, "es.yml"]))
      Linguist.MemorizedVocabulary.t("es-es-es", "flash.notice.alert")
    end

    assert_raise Linguist.LocaleError, fn ->
      Linguist.MemorizedVocabulary.locale(:"es-es-es", Path.join([__DIR__, "es.yml"]))
      Linguist.MemorizedVocabulary.t(:"es-es-es", "flash.notice.alert")
    end

    assert_raise Linguist.LocaleError, fn ->
      Linguist.MemorizedVocabulary.locale(nil, Path.join([__DIR__, "es.yml"]))
      Linguist.MemorizedVocabulary.t(nil, "flash.notice.alert")
    end
  end
end
