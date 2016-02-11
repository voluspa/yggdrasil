defmodule TestCommand do
  defstruct foo: nil, bar: nil, baz: nil
end

defmodule TestParser do
  use Yggdrasil.Command.ParserBuilder

  parse "test :foo", TestCommand
  parse "test :foo :bar", TestCommand
  parse "test :foo :bar :baz", TestCommand
  parse "test :foo if :bar this :baz matters", TestCommand
  parse ":foo", TestCommand
  parse ":foo :foo", TestCommand

end

defmodule ParserBuilderTest do
  use ExUnit.Case
  alias TestParser, as: Parser

  test "parse/1 returns a tagged tuple when parsing is successful" do
    assert {:ok, _cmd} = Parser.parse "test example"
  end

  test "parse/1 sets the fields on the struct based on the placeholder" do
    assert {:ok, cmd} = Parser.parse "test example"
    assert "example" = cmd.foo
  end

  test "parse/1 sets the fields with two placeholders" do
    assert {:ok, cmd} = Parser.parse "test example example2"
    assert %TestCommand{foo: "example", bar: "example2"} = cmd
  end

  test "parse/1 sets the fields with three placeholders" do
    assert {:ok, cmd} = Parser.parse "test example example2 example3"
    assert %TestCommand{foo: "example", bar: "example2", baz: "example3"} = cmd
  end

  test "parse/1 sets the fields with three placeholders with literals in between" do
    assert {:ok, cmd} = Parser.parse "test example if example2 this example3 matters"
    assert %TestCommand{foo: "example", bar: "example2", baz: "example3"} = cmd
  end

  test "parse/1 sets the fields on the struct based on the placeholder only" do
    assert {:ok, cmd} = Parser.parse "example"
    assert "example" = cmd.foo
  end

  test "parse/1 downcases command text" do
    assert {:ok, cmd} = Parser.parse "test EXAMPLE"
    assert "example" = cmd.foo
  end

  test "parse/1 returns :error with reason when parsing is unsuccessful" do
    assert {:error, _reason} = Parser.parse "IHopeOneDay ThisIsn'tACommand"
  end
end
