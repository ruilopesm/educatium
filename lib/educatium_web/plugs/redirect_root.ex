defmodule EducatiumWeb.Plugs.RedirectRoot do
  @moduledoc """
  A plug that redirects the user to the specified path if they visit the root URL.
  """
  def init(opts), do: opts

  def call(conn, opts) do
    IO.inspect(conn)

    if conn.request_path == "/" do
      conn
      |> Phoenix.Controller.redirect(to: opts[:to])
    else
      conn
    end
  end
end
