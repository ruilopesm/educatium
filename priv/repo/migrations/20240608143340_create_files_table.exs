defmodule Educatium.Repo.Migrations.CreateFilesTable do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :resource_id, references(:resources, on_delete: :delete_all, type: :binary_id), null: false
      add :directory_id, references(:directories, on_delete: :delete_all, type: :binary_id), null: false

      add :file, :string

      timestamps(type: :utc_datetime)
    end
  end
end
