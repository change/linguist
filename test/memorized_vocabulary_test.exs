defmodule MemorizedVocabularyTest do
  use ExUnit.Case

  setup do
    foo = Linguist.MemorizedVocabulary.locale("es", Path.join([__DIR__, "es.yml"]))
    {:ok, foo: foo}
  end

  test "it returns locales" do
    assert ["es"] == Linguist.MemorizedVocabulary.locales()
  end
end
