defmodule Educatium.Repo.Migrations.CreateDirectoriesTable do
  use Ecto.Migration

  def change do
    create table(:directories, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false

      add :resource_id, references(:resources, on_delete: :delete_all, type: :binary_id),
        null: false

      add :directory_id, references(:directories, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
