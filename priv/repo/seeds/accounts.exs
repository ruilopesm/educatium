defmodule Educatium.Repo.Seeds.Accounts do
  @moduledoc """
  Seeds the database with everything related to accounts.
  """
  alias Educatium.Accounts
  alias Educatium.Accounts.User
  alias Educatium.Repo

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
    roles = User.roles()

    for user <- users do
      email = build_email(user)

      attrs = %{
        email: email,
        password: "password1234",
      }

      with {:ok, %User{} = registered} <- Accounts.register_user(attrs) do
        [first_name, last_name] = String.split(user, " ")
        setup = %{
          role: Enum.random(roles),
          handle: build_recommended_handle(email),
          first_name: first_name,
          last_name: last_name,
          course: "Software Engineering",
          university: "University of Minho",
        }

        case Accounts.complete_user_setup(registered, setup) do
          {:ok, _} ->
            Accounts.update_user(registered, %{confirmed_at: NaiveDateTime.utc_now()})

          {:error, changeset} ->
            Mix.shell().error(Kernel.inspect(changeset.errors))
        end
      end
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

  defp build_recommended_handle(email) do
    email
    |> String.split("@")
    |> List.first()
  end
end

Educatium.Repo.Seeds.Accounts.run()
