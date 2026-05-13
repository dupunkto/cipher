defmodule Cipher.Key do
  @moduledoc """
  A tagged {en,de}cryption key.
  """
  use TypedEctoSchema

  @primary_key {:id, :string, []}
  typed_schema "encryption_keys" do
    field :key, :binary
    field :expiry, :utc_datetime
    field :uses_left, :integer

    timestamps()
  end
end