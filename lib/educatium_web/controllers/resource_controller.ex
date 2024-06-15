defmodule EducatiumWeb.ResourceController do
  use EducatiumWeb, :controller

  alias Educatium.Resources
  alias Educatium.Resources.Resource

  action_fallback EducatiumWeb.FallbackController

  def index(conn, _params) do
    resources = Resources.list_resources()
    render(conn, :index, resources: resources)
  end

  def create(conn, %{"resource" => resource_params}) do
    with {:ok, %Resource{} = resource} <- Resources.create_resource(resource_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/resources/#{resource}")
      |> render(:show, resource: resource)
    end
  end

  def show(conn, %{"id" => id}) do
    resource = Resources.get_resource!(id)
    render(conn, :show, resource: resource)
  end

  # def update(conn, %{"id" => id, "resource" => resource_params}) do
  #   resource = Resources.get_resource!(id)

  #   with {:ok, %Resource{} = resource} <- Resources.update_resource(resource, resource_params) do
  #     render(conn, :show, resource: resource)
  #   end
  # end
end
