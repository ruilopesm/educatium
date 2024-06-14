defmodule EducatiumWeb.HelloController do
  use EducatiumWeb, :controller

  @app Mix.Project.config()[:app]
  @version Mix.Project.config()[:version]

  def hello(conn, _params) do
    conn
    |> json(%{app: @app, version: @version})
  end

  def test(conn, _params) do
    conn
    |> json(%{validate: "API key is valid!"})
  end
end
