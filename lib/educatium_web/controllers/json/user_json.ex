defmodule EducatiumWeb.UserJSON do
  alias Educatium.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      handle: user.handle,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      role: user.role,
      created_at: user.inserted_at,
      course: user.course,
      university: user.university
    }
  end
end
