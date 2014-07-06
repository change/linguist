defmodule CompilerTest do
  use ExUnit.Case

  test "compiles keyword list of translations into function def AST" do
    assert Linguist.Compiler.compile(en: [foo: "bar"], fr: [foo: "bar"])
  end
end
