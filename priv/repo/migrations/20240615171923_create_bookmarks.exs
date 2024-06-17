defmodule Educatium.Repo.Migrations.CreateBookmarks do
  use Ecto.Migration

  def change do
    create table(:bookmarks, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :resource_id, references(:resources, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:bookmarks, [:user_id, :resource_id], name: :unique_bookmarks)
  end
end
