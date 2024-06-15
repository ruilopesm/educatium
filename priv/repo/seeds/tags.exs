defmodule Educatium.Repo.Seeds.Tags do
  @moduledoc """
  Seeds the database with everything related to tags.
  """
  alias Educatium.Repo
  alias Educatium.Resources
  alias Educatium.Resources.{Resource, Tag}

  @names Resource.types() ++ ~w(
    WebDev
    Graphics
    Math
    Science
    Security
    Networking
    Programming
    Databases
    DevOps
    Mobile
    GameDev
    Design
    Productivity
    Business
    Marketing
    Music
    Photography
    Video
    Writing
  )a

  @colors Tag.colors()

  def run do
    case Repo.all(Tag) do
      [] ->
        seed_tags()
      _ ->
        Mix.shell().error("Found existing tags, skipping seeding.")
    end
  end

  def seed_tags do
    for name <- @names do
      %{
        "name" => stringify_name(name),
        "color" => Enum.random(@colors)
      }
      |> Resources.create_tag()
    end
  end

  defp stringify_name(name) do
    name
    |> Atom.to_string()
    |> String.capitalize()
  end
end

Educatium.Repo.Seeds.Tags.run()
