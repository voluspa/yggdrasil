defmodule Yggdrasil.Message do
  defstruct type: :info, message: nil

  alias Yggdrasil.Message

  def error(:already_registered) do
    %Message {
      type: :error,
      message: """
        A client is already connected for this account.
        This connection will be closed.
        """
    }
  end

  def error(:unknown_command_string) do
    %Message {
      type: :error,
      message: """
        Unknown command.
        """
    }
  end

  def info(text) when is_binary(text) do
    %Message {
      type: :info,
      message: text
    }
  end
end
