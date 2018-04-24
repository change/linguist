defmodule MemorizedVocabularyTest do
  use ExUnit.Case

  setup do
    Linguist.MemorizedVocabulary.locale("es", Path.join([__DIR__, "es.yml"]))
    {:ok, foo: 'bar'}
  end

  test "locales() returns locales" do
    assert ["es"] == Linguist.MemorizedVocabulary.locales()
  end

  test "t returns a translation" do
    assert {:ok, "bar"} == Linguist.MemorizedVocabulary.t("es", "foo")
  end

  test "t interpolates values" do
    assert {:ok, "hola Michael Westin"} == Linguist.MemorizedVocabulary.t("es", "flash.notice.hello", first: "Michael", last: "Westin")
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
end
