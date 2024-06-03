defmodule Educatium.Repo.Seeds.Resources do
  @moduledoc """
  Seeds the database with everything related to resources.
  """
  alias Educatium.Accounts.User
  alias Educatium.Repo
  alias Educatium.Resources
  alias Educatium.Resources.Resource

  def run do
    case Repo.all(Resource) do
      [] ->
        seed_resources()
      _ ->
        Mix.shell().error("Found existing resources, skipping seeding.")
    end
  end

  def seed_resources do
    users = Repo.all(User)
    types = Resource.types()

    for i <- 1..30 do
      type = Enum.random(types)
      str_type = stringify_type(type)

      %{
        title: "#{str_type} #{i}",
        date: Faker.Date.backward(365),
        description: Faker.Lorem.paragraph(),
        type: type,
        visibility: :public,
        user_id: Enum.random(users).id
      }
      |> Resources.create_resource(with_post: true)
    end
  end

  defp stringify_type(type) do
    type
    |> Atom.to_string()
    |> String.capitalize()
  end
end

Educatium.Repo.Seeds.Resources.run()
