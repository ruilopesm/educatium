defmodule Educatium.Repo.Migrations.CreateResourcesTagsTable do
  use Ecto.Migration

  def change do
    create table(:resources_tags, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :resource_id, references(:resources, on_delete: :nothing, type: :binary_id), null: false
      add :tag_id, references(:tags, on_delete: :nothing, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:resources_tags, [:resource_id])
    create index(:resources_tags, [:tag_id])

    create unique_index(:resources_tags, [:resource_id, :tag_id])
  end
end
