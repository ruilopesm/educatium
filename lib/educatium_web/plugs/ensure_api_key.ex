defmodule EducatiumWeb.Plugs.EnsureAPIKey do
  @moduledoc false
  import Plug.Conn

  alias Educatium.Accounts

  @message "API key is invalid or missing. Please provide an appropriate API key."

  def init(opts), do: opts

  def call(%{body_params: params} = conn, _opts) do
    if Map.has_key?(params, "api_key") do
      validate_api_key(conn, params["api_key"])
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, build_body(@message))
      |> halt()
    end
  end

  defp validate_api_key(conn, api_key) do
    if Accounts.is_valid_api_key?(api_key) do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, build_body(@message))
      |> halt()
    end
  end

  defp build_body(message) do
    Jason.encode!(%{
      errors: %{
        detail: message
      }
    })
  end
end
