defmodule Educatium.ResourcesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Educatium.Resources` context.
  """

  @doc """
  Generate a resource.
  """
  def resource_fixture(attrs \\ %{}) do
    {:ok, resource} =
      attrs
      |> Enum.into(%{
        date: ~D[2024-05-28],
        description: "some description",
        published: ~N[2024-05-28 16:32:00],
        title: "some title",
        type: :book,
        visibility: :protected
      })
      |> Educatium.Resources.create_resource()

    resource
  end
end
