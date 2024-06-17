defmodule EducatiumWeb.Plugs.ActiveUser do
  @moduledoc """
  A plug that checks if the current user is confirmed and active.

  If the user is not confirmed, it redirects them to the confirmation setup page.
  If the user is not active, it redirects them to the setup page.
  """
  import EducatiumWeb.Gettext

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) when is_map(conn.assigns.current_user) do
    current_user = conn.assigns.current_user

    with {:ok, conn} <- user_is_confirmed?(conn, current_user),
         {:ok, conn} <- user_is_active?(conn, current_user) do
      conn
    else
      {:error, conn} -> conn
    end
  end

  def call(conn, _opts), do: conn

  defp user_is_confirmed?(conn, current_user) do
    if current_user.confirmed_at do
      {:ok, conn}
    else
      {:error,
       conn
       |> Phoenix.Controller.put_flash(:error, gettext("Please confirm your account"))
       |> Phoenix.Controller.redirect(to: "/users/confirm")}
    end
  end

  defp user_is_active?(conn, current_user) do
    if current_user.active do
      {:ok, conn}
    else
      {:error,
       conn
       |> Phoenix.Controller.put_flash(:error, gettext("Please complete your account setup"))
       |> Phoenix.Controller.redirect(to: "/users/setup")}
    end
  end
end
