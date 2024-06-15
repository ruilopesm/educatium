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

  def user(conn, _params) do
    user = conn.assigns.current_user

    conn
    |> json(%{
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      role: user.role,
      created_at: user.inserted_at,
      course: user.course,
      university: user.university
    })
  end
end
