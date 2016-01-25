defmodule Yggdrasil.Command.ParserBuilder do
  alias Yggdrasil.Command.ParseRule

  defmacro __using__(_) do
    quote do
      Module.register_attribute __MODULE__, :parse_rules, accumulate: true

      import Yggdrasil.Command.ParserBuilder

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro parse(text, command) do
    quote do
      @parse_rules ParseRule.create(unquote(text), unquote(command))
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
            {:ok, unquote(struct)}
          end
        end
      end)

    quote do
      def parse(text) do
        do_parse_command(text |> String.downcase |> String.split)
      end

      unquote(rules)

      defp do_parse_command(_) do
        {:error, :unknown_command_string}
      end
    end
  end
end
