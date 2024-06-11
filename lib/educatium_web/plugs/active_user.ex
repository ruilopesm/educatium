defmodule EducatiumWeb.Plugs.ActiveUser do
  @moduledoc """
  A plug that checks if the current user is active.
  If the user is not active, it redirects them to the setup page.
  """

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = conn.assigns.current_user

    if current_user do
      with {:ok, conn} <- user_confirmed(conn, current_user),
           {:ok, conn} <- user_active(conn, current_user) do
        conn
      else
        {:error, conn} -> conn
      end
    else
      conn
    end
  end

  defp user_confirmed(conn, current_user) do
    if current_user.confirmed_at do
      {:ok, conn}
    else
      {:error, Phoenix.Controller.redirect(conn, to: "/users/confirm")}
    end
  end

  defp user_active(conn, current_user) do
    if current_user.active do
      {:ok, conn}
    else
      {:error, Phoenix.Controller.redirect(conn, to: "/users/setup")}
    end
  end
end
