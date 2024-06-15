defmodule Educatium.Repo.Seeds.Comments do
  @moduledoc """
  Seeds the database with comments.
  """
  alias Educatium.Accounts.User
  alias Educatium.Feed
  alias Educatium.Feed.{Comment, Post}
  alias Educatium.Repo

  def run do
    case Repo.all(Comment) do
      [] ->
        seed_comments()
      _ ->
        Mix.shell().error("Found existing comments, skipping seeding.")
    end
  end

  def seed_comments do
    posts = Repo.all(Post)
    users = Repo.all(User)

    for post <- posts do
      for _ <- 1..Enum.random(3..8) do
        %{
          "body" => Faker.Lorem.paragraph(),
          "post_id" => post.id,
          "user_id" => Enum.random(users).id
        }
        |> Feed.create_comment()
      end
    end
  end
end

Educatium.Repo.Seeds.Comments.run()
