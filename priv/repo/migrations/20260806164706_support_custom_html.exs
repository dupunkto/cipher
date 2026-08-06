defmodule Cipher.Repo.Migrations.SupportCustomHtml do
  use Ecto.Migration

  def change do
    alter table(:inboxes) do
      add :html_head, :text
      add :html_body, :text
    end
  end
end
