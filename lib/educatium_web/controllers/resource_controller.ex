defmodule EducatiumWeb.ResourceController do
  use EducatiumWeb, :controller

  alias Educatium.Resources
  alias Educatium.Resources.Resource

  action_fallback EducatiumWeb.FallbackController

  def index(conn, _params) do
    resources = Resources.list_resources_which_user_can_see(conn.assigns.current_user.id)
    render(conn, :index, resources: resources)
  end

  def create(conn, %{"resource" => resource_params}) do
    # TODO: upload resource with multipart
    with {:ok, %Resource{} = resource} <- Resources.create_resource(resource_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/resources/#{resource}")
      |> render(:show, resource: resource)
    end
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    resource = Resources.get_resource!(id)

    if Resources.can_see_resource(conn.assigns.current_user.id, resource) do
      render(conn, :show, resource: resource)
    else
      conn
      |> put_status(:forbidden)
      |> render(:error, message: "You are not allowed to see this resource")
    end
  end

  def update(conn, %{"id" => id, "resource" => resource_params}) do
    resource = Resources.get_resource!(id)

    if resource.user_id == conn.assigns.current_user.id do
      # TODO: fixme
      # TODO: check to only accept allowed fields to be modified
      with {:ok, %Resource{} = resource} <- Resources.update_resource(resource, resource_params) do
        render(conn, :show, resource: resource)
      end
    else
    end
  end
end
