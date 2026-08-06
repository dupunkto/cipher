defmodule Cipher.Inbox do
  @moduledoc """
  An inbox for receiving encrypted links via email.
  """
  use TypedEctoSchema

  @primary_key {:id, :binary_id, autogenerate: true}
  typed_schema "inboxes" do
    field :slug, :string
    field :email, :string
    field :html_head, :string
    field :html_body, :string

    timestamps()
  end
end