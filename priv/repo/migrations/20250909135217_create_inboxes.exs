defmodule Cipher.Repo.Migrations.CreateInboxes do
  use Ecto.Migration

  def change do
    create table(:inboxes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :email, :string, null: false

      timestamps()
    end

    create unique_index(:inboxes, [:slug])
  end
end
