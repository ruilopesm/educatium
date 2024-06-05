defmodule EducatiumWeb.Plugs.ActiveUser do
  @moduledoc """
  A plug that checks if the current user is active.
  If the user is not active, it redirects them to the setup page.
  """

  use EducatiumWeb, :verified_routes

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = conn.assigns.current_user

    if current_user && !current_user.active do
      conn
      |> Phoenix.Controller.redirect(to: ~p"/users/setup")
    else
      conn
    end
  end
end
