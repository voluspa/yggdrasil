defmodule Yggdrasil.Command.ParseRule do
  defstruct cmd_segs: [], cmd_struct: nil

  alias Yggdrasil.Command.ParseRule

  def create(text, struct) when is_binary(text) do
    segments =
      text
      |> String.downcase
      |> String.split
      |> tag_segments()

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
