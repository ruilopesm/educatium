defmodule Educatium.Repo.Migrations.CreateUpvotesTable do
  use Ecto.Migration

  def change do
    create table(:upvotes, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :post_id, references(:posts, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:upvotes, [:user_id, :post_id], name: :unique_upvotes)
  end
end
