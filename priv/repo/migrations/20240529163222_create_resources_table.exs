defmodule Educatium.Repo.Migrations.CreateResourcesTable do
  use Ecto.Migration

  def change do
    create table(:resources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :type, :string, null: false
      add :date, :date
      add :visibility, :string, null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
