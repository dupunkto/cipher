defmodule Cipher.Repo.Migrations.CreateEncryptionKeys do
  use Ecto.Migration

  def change do
    create table(:encryption_keys, primary_key: false) do
      add :id, :string, primary_key: true
      add :key, :binary, null: false
      add :expiry, :utc_datetime, null: false
      add :uses_left, :integer, null: false

      timestamps()
    end

    create index(:encryption_keys, [:expiry])
  end
end
