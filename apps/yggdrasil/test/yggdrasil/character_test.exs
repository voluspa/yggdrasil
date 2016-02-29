defmodule Yggdrasil.CharacterTest do
  use ExUnit.Case, async: false

  alias Yggdrasil.{Repo, Game, Character}

  @min_len 3

  @game1   %{name: "abcdef", description: "abcdefghi"}
  @game2   %{name: "ghijkl", description: "abcdefghi"}

  @character %{name: "foobar", ext_id: nil, game_id: nil}
  @invalid_character %{name: "ab", ext_id: nil, game_id: nil}

  @invalid_length_msg "should be at least %{count} character(s)"
  @missing_assoc_msg "does not exist"
  @unique_msg "has already been taken"
  @required_msg "can't be blank"

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Yggdrasil.Repo, [])
    end

    :ok
  end

  setup _context do
    {:ok, game1} = %Game{}
    |> Game.changeset(@game1)
    |> Repo.insert

    {:ok, game2} = %Game{}
    |> Game.changeset(@game2)
    |> Repo.insert

    {:ok, %{ext1: 123456, ext2: 10111213, game1: game1, game2: game2}}
  end

  test "valid character produces a valid changeset", ctx do
    game = ctx.game1

    valid_character = %{@character | ext_id: ctx.ext1, game_id: game.id}

    character = Character.changeset(%Character{}, valid_character)
    assert character.valid? == true
  end

  test "valid character changset with valid references inserts", ctx do
    game = ctx.game1

    valid_character = %{@character | ext_id: ctx.ext1, game_id: game.id}

    character = Character.changeset(%Character{}, valid_character)
    assert character.valid? == true

    {:ok, _character} = Repo.insert character
  end

  test "invalid character name length < #{@min_len}" do
    character = Character.changeset(%Character{}, @invalid_character)
    assert character.valid? == false
  end

  test "character changset requires game_id" do
    valid_character = %{@character | ext_id: 0}

    character = Character.changeset(%Character{}, valid_character)
    assert character.valid? == false
    assert {:game_id, @required_msg} in character.errors
  end

  test "character changset requires ext_id" do
    valid_character = %{@character | game_id: 0}

    character = Character.changeset(%Character{}, valid_character)
    assert character.valid? == false 
    assert {:ext_id, @required_msg} in character.errors
  end

  test "valid character changset assoc_constraint fires on invalid game", ctx do
    valid_character = %{@character | ext_id: ctx.ext1, game_id: 0}

    character = Character.changeset(%Character{}, valid_character)
    assert character.valid? == true

    {:error, changeset} = Repo.insert character
    assert {:game, @missing_assoc_msg} in changeset.errors
  end

  test "same character name can be used if the game_id is different with the same ext_id", ctx do
    valid_character1 = %{@character | ext_id: ctx.ext1, game_id: ctx.game1.id}
    valid_character2 = %{@character | ext_id: ctx.ext1, game_id: ctx.game2.id}

    assert {:ok, _char} = %Character{} |> Character.changeset(valid_character1) |> Repo.insert
    assert {:ok, _char} = %Character{} |> Character.changeset(valid_character2) |> Repo.insert
  end

  test "same character name can be used if the game_id is different and the ext_id", ctx do
    valid_character1 = %{@character | ext_id: ctx.ext1, game_id: ctx.game1.id}
    valid_character2 = %{@character | ext_id: ctx.ext2, game_id: ctx.game2.id}

    assert {:ok, _char} = %Character{} |> Character.changeset(valid_character1) |> Repo.insert
    assert {:ok, _char} = %Character{} |> Character.changeset(valid_character2) |> Repo.insert
  end

  test "same character name fails if game_id is the same with same ext_id", ctx do
    valid_character = %{@character | ext_id: ctx.ext1, game_id: ctx.game1.id}

    assert {:ok, _char} = %Character{} |> Character.changeset(valid_character) |> Repo.insert
    assert {:error, changeset} = %Character{} |> Character.changeset(valid_character) |> Repo.insert

    assert {:name, @unique_msg} in changeset.errors
  end

  test "same character name fails if game_id is the same with different ext_ids", ctx do
    valid_character1 = %{@character | ext_id: ctx.ext1, game_id: ctx.game1.id}
    valid_character2 = %{@character | ext_id: ctx.ext2, game_id: ctx.game1.id}

    assert {:ok, _char} = %Character{} |> Character.changeset(valid_character1) |> Repo.insert
    assert {:error, changeset} = %Character{} |> Character.changeset(valid_character2) |> Repo.insert

    assert {:name, @unique_msg} in changeset.errors
  end
end
