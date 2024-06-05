defmodule Educatium.FeedFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Educatium.Feed` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        type: :resource
      })
      |> Educatium.Feed.create_post()

    post
  end
end
