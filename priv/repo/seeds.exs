defmodule Educatium.Repo.Seeds do
  @moduledoc """
  Script for seeding the database with initial data.

  This script is executed by running `mix ecto.seed`.
  """

  @seeds_dir "priv/repo/seeds"

  def run do
    ["accounts.exs", "tags.exs", "resources.exs"]
    |> Enum.each(fn file ->
      Code.require_file(Path.join(@seeds_dir, file))
    end)
  end
end

Educatium.Repo.Seeds.run()
