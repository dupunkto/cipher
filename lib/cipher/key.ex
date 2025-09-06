defmodule Cipher.Key do
  @moduledoc """
  A tagged {en,de}cryption key.
  """
  use Ecto.Schema

  @primary_key {:id, :string, []}
  schema "encryption_keys" do
    field :key, :binary
    field :expiry, :utc_datetime
    field :uses_left, :integer

    timestamps()
  end
end