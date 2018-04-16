defmodule EscapingTest do
  use ExUnit.Case

  defmodule Esc do
    use Linguist.Vocabulary

    locale("en", [])

    locale(
      "fr",
      level: [
        basic: "%%{escaped}",
        mixed: "%{a} %%{a} %{a} %%{a}"
      ]
    )
  end

  test "t does not escape %%{ but replaces %% by %" do
    assert Esc.t!("fr", "level.basic") == "%{escaped}"
  end

  test "even if key is in the binding" do
    assert Esc.t!("fr", "level.basic", escaped: "Does not matter") == "%{escaped}"
  end

  test "mixed form" do
    assert Esc.t!("fr", "level.mixed", a: 42) == "42 %{a} 42 %{a}"
  end

  test "mixed form, no values" do
    assert_raise KeyError, fn ->
      Esc.t!("fr", "level.mixed")
    end
  end
end
