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

  @doc """
  Generate a announcement.
  """
  def announcement_fixture(attrs \\ %{}) do
    {:ok, announcement} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title"
      })
      |> Educatium.Feed.create_announcement()

    announcement
  end
end
