defmodule Educatium.Repo.Migrations.CreateTagsTable do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :citext, null: false
      add :color, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tags, [:name], name: :unique_tags)
  end
end
