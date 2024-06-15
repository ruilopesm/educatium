defmodule EducatiumWeb.Plugs.EnsureAPIKey do
  @moduledoc """
  A plug that ensures the presence of a valid API key in the request.
  """
  @behaviour Plug

  import Plug.Conn

  alias Educatium.Accounts

  @message "API key is invalid or missing. Please provide an appropriate API key."

  def init(opts), do: opts

  def call(conn, _opts) do
    api_key = get_req_header(conn, "authorization")
    if length(api_key) > 0 && hd(api_key) && Accounts.is_valid_api_key?(hd(api_key)) do
      user = Accounts.get_user_by_api_key(hd(api_key))
      assign(conn, :current_user, user)
    else
      unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, build_body!(@message))
    |> halt()
  end

  defp build_body!(message) do
    Jason.encode!(%{
      errors: %{
        detail: message
      }
    })
  end
end
