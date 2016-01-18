defprotocol Yggdrasil.Command do
  def execute(player, cmd)
end

defmodule Yggdrasil.Command.MoveCommand do
  defstruct exit: nil
end

defimpl Yggdrasil.Command, for: Yggdrasil.Command.MoveCommand do
  def execute(player, cmd) do
    Yggdrasil.Player.notify player, "You head towards #{cmd.exit}"
  end
end

defmodule Yggdrasil.Command.Parser.ParseRule do
  defstruct cmd_segs: [], cmd_struct: nil

  alias Yggdrasil.Command.Parser.ParseRule

  def create(text, struct) when is_binary(text) do
    segments = String.split(text) |> tag_segments()
    %ParseRule{ cmd_segs: segments, cmd_struct: struct }
  end

  defp tag_segments(segments), do: do_tag_segments(segments, [])

  defp do_tag_segments([], segments) do
    Enum.reverse segments
  end

  defp do_tag_segments([":" <> var | t], segments) do
    do_tag_segments t, [{:identifier, var, String.to_atom(var)} | segments]
  end

  defp do_tag_segments([h|t], segments) do
    do_tag_segments t, [{:literal, h} | segments]
  end
end

defmodule Yggdrasil.Command.Parser do
  alias Yggdrasil.Command.Parser.ParseRule

  defmacro __using__(_) do
    quote do
      Module.register_attribute __MODULE__, :parse_rules, accumulate: true

      import Yggdrasil.Command.Parser

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro parse(text, command) do
    quote do
      @parse_rules ParseRule.create(unquote(text), unquote(command))

      def parse_command(text) do
        do_parse_command(String.split(text))
      end
    end
  end

  defmacro __before_compile__(env) do
    rules = env.module
      |> Module.get_attribute(:parse_rules)
      |> Enum.reverse
      |> Enum.map(fn rule ->
        match = Enum.map(rule.cmd_segs, fn(seg) ->
          case seg do
            {:literal, text} -> text
            {:identifier, _var, atom} -> {atom, [], nil}
          end
        end)

    attrs = rule.cmd_segs
      |> Enum.filter(fn
          ({:identifier, _, _}) -> true
          ({:literal, _}) -> false
        end)
      |> Enum.map(fn({:identifier, _, atom}) ->
        {atom, {atom, [], nil}}
      end)

    struct = {:%, [],
              [{:__aliases__, [alias: false], [rule.cmd_struct]},
              {:%{}, [], attrs}]}

        quote do
          defp do_parse_command(unquote(match)) do
            unquote(struct)
          end
        end
      end)

    quote do
      unquote(rules)
    end
  end
end

defmodule Yggdrasil.Command.DefaultParser do
  use Yggdrasil.Command.Parser

  alias Yggdrasil.Command.MoveCommand

  parse "go :exit", MoveCommand
  parse "move :exit", MoveCommand
  parse ":exit", MoveCommand
end

