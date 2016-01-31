defmodule ParseRuleTest do
  use ExUnit.Case
  alias Yggdrasil.Command.ParseRule

  test "create/2 given one literal and one identifier as text and Struct produces a parse rule." do
    rule = %ParseRule{
      cmd_segs: [{:literal, "test"},{:identifier, "bar", :bar}],
      cmd_struct: Test
    }

    assert rule == ParseRule.create("test :bar", Test)
  end

  test "create/2 given two literals in sequence and one identifier after as text and Struct produces a parse rule with order preserved" do
    rule = %ParseRule{
      cmd_segs: [{:literal, "test"}, {:literal, "foo"} ,{:identifier, "bar", :bar}],
      cmd_struct: Test
    }

    assert rule == ParseRule.create("test foo :bar", Test)
  end

  test "create/2 given one literal and two identifiers in sequence text and Struct produces a parse rule with order preserved" do
    rule = %ParseRule{
      cmd_segs: [
        {:literal, "test"},
        {:identifier, "bar", :bar},
        {:identifier, "baz", :baz}
      ],
      cmd_struct: Test
    }

    assert rule == ParseRule.create("test :bar :baz", Test)
  end

  test "create/2 given two literals and two identifiers interspersed as text and Struct produces a parse rule with order preserved" do
    rule = %ParseRule{
      cmd_segs: [
        {:literal, "test"},
        {:identifier, "bar", :bar},
        {:literal, "foo"},
        {:identifier, "baz", :baz}
      ],
      cmd_struct: Test
    }

    assert rule == ParseRule.create("test :bar foo :baz", Test)
  end
end
