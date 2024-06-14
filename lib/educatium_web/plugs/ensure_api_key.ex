defmodule EducatiumWeb.Plugs.EnsureAPIKey do
  @moduledoc """
  A plug that ensures the presence of a valid API key in the request.
  """
  @behaviour Plug

  import Plug.Conn

  alias Educatium.Accounts

  @message "API key is invalid or missing. Please provide an appropriate API key."

  def init(opts), do: opts

  def call(%{body_params: params} = conn, _opts) when is_map_key(params, "api_key") do
    if is_binary(params["api_key"]) and Accounts.is_valid_api_key?(params["api_key"]) do
      conn
    else
      unauthorized(conn)
    end
  end

  def call(conn, _opts), do: unauthorized(conn)

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
