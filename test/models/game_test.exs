defmodule Yggdrasil.GameTest do
  use Yggdrasil.ModelCase

  alias Yggdrasil.Game

  @min_len 3
  @valid_game                 %{name: "abcdef", description: "abcdefghi"}
  @invalid_name_game          %{@valid_game | name: "ab"}
  @invalid_description_game   %{@valid_game | description: "ab"}
  @invalid_game %{name: "ab", description: "bs"}

  @invalid_length_msg "should be at least %{count} character(s)"
  @unique_msg "has already been taken"

  test "valid game produces valid changeset" do
    game = Game.changeset %Game{}, @valid_game

    assert game.valid? == true
  end

  test "invalid game produces invalid changeset" do
    game = Game.changeset %Game{}, @invalid_game

    assert game.valid? == false
  end

  test "name less than {@min_len} produces min length error" do
    game = Game.changeset %Game{}, @invalid_game

    assert game.valid? == false
    assert {:name, {@invalid_length_msg, [count: @min_len]}} in game.errors
  end

  test "description less than #{@min_len} produces min length error" do
    game = Game.changeset %Game{}, @invalid_game

    assert game.valid? == false
    assert {:description, {@invalid_length_msg, [count: @min_len]}} in game.errors
  end

  test "unique constraint on game name is obeyed" do
    game = Game.changeset %Game{}, @valid_game
    {:ok, _game} = Repo.insert game

    {:error, changeset} = Repo.insert game
    assert {:name, @unique_msg} in changeset.errors
  end
end
