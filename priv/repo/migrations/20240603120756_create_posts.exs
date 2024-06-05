defmodule Educatium.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :upvotes_count, :integer, default: 0
      add :downvotes_count, :integer, default: 0
      add :type, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:posts, [:inserted_at, :id])

    alter table(:resources) do
      add :post_id, references(:posts, type: :binary_id)
    end
  end
end
