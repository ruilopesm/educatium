defmodule Educatium.Repo.Migrations.CreateTeachersTable do
  use Ecto.Migration

  def change do
    create table(:teachers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :university, :string, null: false
      add :course, :string, null: false
      add :department, :string, null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end
  end
end
