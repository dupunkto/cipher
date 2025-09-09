defmodule Cipher.Inbox do
  @moduledoc """
  An inbox for receiving encrypted links via email.
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "inboxes" do
    field :slug, :string
    field :email, :string

    timestamps()
  end
end