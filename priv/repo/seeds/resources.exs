defmodule Educatium.Repo.Seeds.Resources do
  @moduledoc """
  Seeds the database with everything related to resources.
  """
  alias Educatium.Accounts.User
  alias Educatium.Repo
  alias Educatium.Resources
  alias Educatium.Resources.{Resource, Tag}

  @types Resource.types()

  def run do
    case Repo.all(Resource) do
      [] ->
        seed_resources()
        seed_resources_tags()
      _ ->
        Mix.shell().error("Found existing resources, skipping seeding.")
    end
  end

  def seed_resources do
    users = Repo.all(User)

    for i <- 1..30 do
      type = Enum.random(@types)

      %{
        "title" => "#{stringify_type(type)} #{i}",
        "date" => Faker.Date.backward(365),
        "description" => Faker.Lorem.paragraph(),
        "type" => type,
        "visibility" => "public",
        "user_id" => Enum.random(users).id
      }
      |> Resources.create_resource()
    end
  end

  def seed_resources_tags do
    resources = Repo.all(Resource)
    tags = Repo.all(Tag)

    for resource <- resources do
      tags
      |> Enum.shuffle()
      |> Enum.take(Enum.random(2..5))
      |> Enum.each(&Resources.create_resource_tag(resource.id, &1.id))
    end
  end

  defp stringify_type(type) do
    type
    |> Atom.to_string()
    |> String.capitalize()
  end
end

Educatium.Repo.Seeds.Resources.run()
