defmodule Educatium.Repo.Seeds.Announcements do
  @moduledoc """
  Seeds the database with announcements.
  """
  alias Educatium.Accounts.User
  alias Educatium.Feed
  alias Educatium.Feed.Announcement
  alias Educatium.Repo

  def run do
    case Repo.all(Announcement) do
      [] ->
        seed_announcements()
      _ ->
        Mix.shell().error("Found existing announcements, skipping seeding.")
    end
  end

  def seed_announcements do
    users =
      Repo.all(User)
      |> Enum.filter(& &1.role == :admin)

    for i <- 1..10 do
      %{
        "title" => "Announcement #{i}",
        "body" => Faker.Lorem.paragraph(),
        "user_id" => Enum.random(users).id
      }
      |> Feed.create_announcement()
    end
  end
end

Educatium.Repo.Seeds.Announcements.run()
