defmodule EducatiumWeb.UserController do
  use EducatiumWeb, :controller

  def user(conn, _params) do
    user = conn.assigns.current_user

    conn
    |> json(%{
      handle: user.handle,
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
