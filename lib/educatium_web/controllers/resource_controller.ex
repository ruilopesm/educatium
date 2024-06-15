defmodule EducatiumWeb.ResourceController do
  use EducatiumWeb, :controller

  def get_resource(conn, %{"id" => id} = _params) do
    # Fix when invalid is is provided and when resource does not exist
    with resource <- Educatium.Resources.get_resource!(id) do
      conn
      |> json(%{
        id: resource.id,
        title: resource.title,
        description: resource.description,
        type: resource.type,
        created_at: resource.inserted_at,
        date: resource.date,
        visibility: resource.visibility,
        user_id: resource.user_id,
        post_id: resource.post_id
      })
    else
      :error ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Resource not found"})
    end
  end

  def get_resource(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Invalid request"})
  end

  def get_resources(_conn, _params) do
  end
end
