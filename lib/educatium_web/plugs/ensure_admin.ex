defmodule EducatiumWeb.Plugs.EnsureAdmin do
  @moduledoc """
  A plug that checks if the current user is an admin.

  If the user is not an admin, it redirects them to the 404 page.
  """

  def init(opts), do: opts

  def call(conn, _opts) when is_map(conn.assigns.current_user) do
    current_user = conn.assigns.current_user

    if current_user.role == :admin do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: "/404")
    end
  end

  def call(conn, _opts), do: conn
end
