defmodule Educatium.Repo.Migrations.CreateAnnouncementsTable do
  use Ecto.Migration

  def change do
    create table(:announcements, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :title, :string
      add :body, :text

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :post_id, references(:posts, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
