defmodule ParserTest do
  use ExUnit.Case
  alias Yggdrasil.Command.Parser

  test "parse/1 returns a tagged tuple when parsing is successful" do
    assert {:ok, _cmd} = Parser.parse "move east"
  end

  test "parse/1 sets the fields on the struct based on the placeholder" do
    assert {:ok, cmd} = Parser.parse "move east"
    assert "east" = cmd.exit
  end

  test "parse/1 downcases command text" do
    assert {:ok, cmd} = Parser.parse "Move EAST"
    assert "east" = cmd.exit
  end

  test "parse/1 returns :error with reason when parsing is unsuccessful" do
    assert {:error, _reason} = Parser.parse "IHopeOneDay ThisIsn'tACommand"
  end
end
