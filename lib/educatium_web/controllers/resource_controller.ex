defmodule EducatiumWeb.ResourceController do
  use EducatiumWeb, :controller

  def get_resource(conn, params) do
    ## Extract resource_id from params
    id = Map.get(params, "id")
    resource = Educatium.Resources.get_resource!(id)

    ## Return resource
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
  end
end
