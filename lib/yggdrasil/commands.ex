defprotocol Command do
  def execute(player, cmd)
end

defmodule Command.Parser do

  parse "go :exit", MoveCommand
  parse "move :exit", MoveCommand
  parse ":exit", MoveCommand
end

defmodule MoveCommand do
  defstruct exit: nil

  defimpl Command, for: MoveCommand do
    def execute(player, cmd) do

    end
  end
end
