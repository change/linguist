defmodule MemorizedVocabularyTest do
  use ExUnit.Case

  setup do
    foo = Linguist.MemorizedVocabulary.locale("es", Path.join([__DIR__, "es.yml"]))
    {:ok, foo: foo}
  end

  test "it returns locales" do
    assert ["es"] == Linguist.MemorizedVocabulary.locales()
  end

  test "it returns a translation" do
    assert {:ok, "bar"} == Linguist.MemorizedVocabulary.t("es", "foo")
  end

  test "it interpolates values" do
    assert {:ok, "hola Michael Westin"} == Linguist.MemorizedVocabulary.t("es", "flash.notice.hello", first: "Michael", last: "Westin")
  end

  test "it pluralizes" do
    assert {:ok, "2 manzanas"} == Linguist.MemorizedVocabulary.t("es", "apple", count: 2)
  end
end
