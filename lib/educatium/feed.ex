defmodule Educatium.Feed do
  @moduledoc """
  The Feed context.
  """
  use Educatium, :context

  alias Educatium.Feed.Post
  alias Educatium.Resources.Resource

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(opts \\ []) do
    Post
    |> join(:left, [p], r in Resource, on: r.post_id == p.id)
    |> where([_, r], r.visibility == :public)
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Returns the list of resources that match the given query.

  ## Examples

      iex> search_posts("elixir")
      [%Post{}, ...]
  """
  def search_posts(query, opts \\ []) do
    Post
    |> join(:left, [p], r in Resource, on: r.post_id == p.id)
    |> where([_, r], ilike(r.title, ^"%#{query}%"))
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, ...}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, ...}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, ...}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns a data structure for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Todo{...}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @topic "posts"

  @doc """
  Subscribes to the posts topic.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(Educatium.PubSub, @topic)
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({1, [post]}, event) do
    Phoenix.PubSub.broadcast(Educatium.PubSub, @topic, {event, post})
    {:ok, post}
  end
end
