defmodule Educatium.Repo.Seeds.Accounts do
  @moduledoc """
  Seeds the database with everything related to accounts.
  """
  alias Educatium.Repo
  alias Educatium.Accounts
  alias Educatium.Accounts.User

  def run do
    case Repo.all(User) do
      [] ->
        seed_users()
      _ ->
        Mix.shell().error("Found existing users, skipping seeding.")
    end
  end

  def seed_users do
    users = gather_users()

    for user <- users do
      email = build_email(user)

      %{
        email: email,
        password: "password1234",
      }
      |> Accounts.register_user()
    end
  end

  defp gather_users do
    "priv/fake/users.txt"
    |> File.read!()
    |> String.split("\n")
  end

  defp build_email(user) do
    user
    |> String.downcase()
    |> String.replace(~r/\s*/, "") # Remove all whitespaces
    |> Kernel.<>("@educatium.com")
  end
end

Educatium.Repo.Seeds.Accounts.run()
