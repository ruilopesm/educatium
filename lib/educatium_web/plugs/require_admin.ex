defmodule EducatiumWeb.Plugs.RequireAdmin do
  @moduledoc """
  A plug that checks if the current user is an admin.

  If the user is not an admin, it redirects them to the 404 page.
  """
  import Plug.Conn

  alias Educatium.Accounts

  def init(opts), do: opts

  def call(conn, opts) when is_map(conn.assigns.current_user) do
    case opts[:type] do
      :web -> check_on_web(conn)
      :api -> check_on_api(conn)
    end
  end

  def call(conn, _opts), do: conn

  defp check_on_web(conn) do
    current_user = conn.assigns.current_user

    if current_user.role == :admin do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: "/404")
    end
  end

  @message "You are not authorized to access this resource."

  defp check_on_api(conn) do
    api_key = get_req_header(conn, "authorization")
    user = Accounts.get_user_by_api_key(hd(api_key))

    if user.role == :admin do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:not_found, build_body!(@message))
      |> halt()
    end
  end

  defp build_body!(message) do
    Jason.encode!(%{
      errors: %{
        detail: message
      }
    })
  end
end
