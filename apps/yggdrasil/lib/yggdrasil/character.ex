defmodule Yggdrasil.Character do
  use Ecto.Schema
  import Ecto.Changeset

  schema "characters" do
    field :name, :string
    field :ext_id, :id
    belongs_to :game, Yggdrasil.Game

    timestamps
  end

  @required_fields ~w(name ext_id game_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name, name: :characters_name_game_id_index)
    |> assoc_constraint(:game)
    |> validate_length(:name, min: 3)
  end
end
