defmodule Yggdrasil.Command.Parser do
  use Yggdrasil.Command.ParserBuilder

  alias Yggdrasil.Command.MoveCommand

  parse "go :exit", MoveCommand
  parse "move :exit", MoveCommand
  parse ":exit", MoveCommand
end
