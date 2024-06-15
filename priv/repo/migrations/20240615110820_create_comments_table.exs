defmodule Educatium.Repo.Migrations.CreateCommentsTable do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :body, :string

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :post_id, references(:posts, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:user_id])
    create index(:comments, [:post_id])
  end
end
