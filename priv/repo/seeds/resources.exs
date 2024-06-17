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

    "priv/fake/resources.json"
    |> File.read!()
    |> Jason.decode!()
    |> Enum.each(fn resource ->
      %{
        "title" => resource["title"],
        "description" => resource["description"],
        "date" => resource["date"],
        "type" => resource["type"],
        "visibility" => resource["visibility"],
        "user_id" => Enum.random(users).id
      }
      |> Resources.create_resource(build_path(resource["path"]))
    end)
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

  defp build_path(path), do: File.cwd!() <> "/priv/fake/resources/" <> path
end

Educatium.Repo.Seeds.Resources.run()
