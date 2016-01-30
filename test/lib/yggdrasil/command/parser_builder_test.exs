defmodule TestCommand do
  defstruct bar: nil
end

defmodule TestParser do
  use Yggdrasil.Command.ParserBuilder

  parse "test :bar", TestCommand
  parse ":bar", TestCommand
  parse ":bar :bar", TestCommand

end

defmodule ParserBuilderTest do
  use ExUnit.Case
  alias TestParser, as: Parser

  test "parse/1 returns a tagged tuple when parsing is successful" do
    assert {:ok, _cmd} = Parser.parse "test baz"
  end

  test "parse/1 sets the fields on the struct based on the placeholder" do
    assert {:ok, cmd} = Parser.parse "test baz"
    assert "baz" = cmd.bar
  end

  test "parse/1 sets the fields on the struct based on the placeholder only" do
    assert {:ok, cmd} = Parser.parse "baz"
    assert "baz" = cmd.bar
  end

  test "parse/1 downcases command text" do
    assert {:ok, cmd} = Parser.parse "test BAZ"
    assert "baz" = cmd.bar
  end

  test "parse/1 returns :error with reason when parsing is unsuccessful" do
    assert {:error, _reason} = Parser.parse ":bar baz"
  end

  test "parse/1 returns :error with reason when parsing is unsuccessful" do
    assert {:error, _reason} = Parser.parse "IHopeOneDay ThisIsn'tACommand"
  end
end
