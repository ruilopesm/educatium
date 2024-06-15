defmodule EducatiumWeb.ResourceJSON do
  alias Educatium.Resources.Resource

  @doc """
  Renders a list of resources.
  """
  def index(%{resources: resources}) do
    %{data: for(resource <- resources, do: data(resource))}
  end

  @doc """
  Renders a single resource.
  """
  def show(%{resource: resource}) do
    %{data: data(resource)}
  end

  defp data(%Resource{} = resource) do
    %{
      id: resource.id,
      title: resource.title,
      description: resource.description,
      type: resource.type,
      created_at: resource.inserted_at,
      date: resource.date,
      visibility: resource.visibility,
      user_id: resource.user_id,
      post_id: resource.post_id
    }
  end
end
