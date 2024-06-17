defmodule EducatiumWeb.UserController do
  use EducatiumWeb, :controller

  alias Educatium.Accounts
  alias Educatium.Accounts.User

  action_fallback EducatiumWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def myself(conn, _params) do
    user = conn.assigns.current_user
    render(conn, :show, user: user)
  end
end
