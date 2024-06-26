defmodule Educatium.Feed do
  @moduledoc """
  The Feed context.
  """
  use Educatium, :context

  alias Educatium.Accounts.User
  alias Educatium.Feed.{Announcement, Comment, Downvote, Post, Upvote}
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
    |> join(:left, [p, _], a in Announcement, on: a.post_id == p.id)
    |> where([_, r, a], r.visibility == :public or not is_nil(a.id))
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Returns the list of posts that match the given query.

  ## Examples

      iex> search_posts("elixir")
      [%Post{}, ...]

  """
  def search_posts(query, opts \\ []) do
    Post
    |> join(:left, [p], r in Resource, on: r.post_id == p.id)
    |> join(:left, [p, _], a in Announcement, on: a.post_id == p.id)
    |> where([_, r, a], ilike(r.title, ^"%#{query}%") or ilike(a.title, ^"%#{query}%"))
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Returns the list of posts filtered by a given resource type.

  ## Examples

      iex> filter_posts(filter, opts)
      [%Post{}, ...]

  """
  def filter_posts(filter, opts \\ []) do
    Post
    |> join(:left, [p], r in Resource, on: r.post_id == p.id)
    |> where([_, r], r.type == ^filter)
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
  def get_post!(id, preloads \\ []) do
    Repo.get!(Post, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Increments a post's view count by one.

  Raises if the Post does not exist.

  ## Examples

      iex> increment_post_views!(123)
      %Post{...}

  """
  def increment_post_views!(post_id) do
    post = get_post!(post_id)

    post
    |> Post.changeset(%{view_count: post.view_count + 1})
    |> Repo.update()
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
      %Post{}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc """
  Gets a post's upvote.

  ## Examples

      iex> get_upvote!(post, user)
      %Upvote{}
  """
  def get_upvote!(%Post{} = post, %User{} = user) do
    Upvote
    |> where([u], u.post_id == ^post.id and u.user_id == ^user.id)
    |> Repo.one!()
  end

  @doc """
  Upvotes a post, by creating an upvote for the given user.
  This upvote creation will, automatically, increment the post's `upvote_count` field.

  ## Examples

      iex> upvote_post!(post, user)
      %Post{}

  """
  def upvote_post!(%Post{} = post, %User{} = user) do
    %Upvote{}
    |> Upvote.changeset(%{post_id: post.id, user_id: user.id})
    |> Repo.insert!()

    updated_post = get_post!(post.id, Post.preloads())
    broadcast({1, updated_post}, :post_updated)
    updated_post
  end

  @doc """
  Deletes an upvote for the given user and post.

  ## Examples

        iex> delete_upvote!(post, user)
        %Post{}

  """
  def delete_upvote!(%Post{} = post, %User{} = user) do
    upvote = get_upvote!(post, user)

    Multi.new()
    |> Multi.delete(:upvote, upvote)
    |> Multi.update(:post, Post.changeset(post, %{upvote_count: post.upvote_count - 1}))
    |> Repo.transaction()

    updated_post = get_post!(post.id, Post.preloads())
    broadcast({1, updated_post}, :post_updated)
    updated_post
  end

  @doc """
  Gets a post's downvote.

  ## Examples

      iex> get_downvote!(post, user)
      %Downvote{}

  """
  def get_downvote!(%Post{} = post, %User{} = user) do
    Downvote
    |> where([d], d.post_id == ^post.id and d.user_id == ^user.id)
    |> Repo.one!()
  end

  @doc """
  Downvotes a post, by creating a downvote for the given user.
  This downvote creation will, automatically, increment the post's `downvote_count` field.

  ## Examples

      iex> downvote_post!(post, user)
      %Post{}
  """
  def downvote_post!(%Post{} = post, %User{} = user) do
    %Downvote{}
    |> Downvote.changeset(%{post_id: post.id, user_id: user.id})
    |> Repo.insert!()

    updated_post = get_post!(post.id, Post.preloads())
    broadcast({1, updated_post}, :post_updated)
    updated_post
  end

  def delete_downvote!(%Post{} = post, %User{} = user) do
    downvote = get_downvote!(post, user)

    Multi.new()
    |> Multi.delete(:downvote, downvote)
    |> Multi.update(:post, Post.changeset(post, %{downvote_count: post.downvote_count - 1}))
    |> Repo.transaction()

    updated_post = get_post!(post.id, Post.preloads())
    broadcast({1, updated_post}, :post_updated)
    updated_post
  end

  @doc """
  Inverts a vote for the given user and post.
  Receives the type of vote to invert, which can be either `:upvote` or `:downvote`.

  ## Examples

      iex> invert_vote!(post, user, type: :upvote)
      %Post{}

      iex> invert_vote!(post, user, type: :downvote)
      %Post{}

  """
  def invert_vote!(%Post{} = post, %User{} = user, type: type) do
    case type do
      :upvote -> convert_downvote_to_upvote(post, user)
      :downvote -> convert_upvote_to_downvote(post, user)
    end

    updated_post = get_post!(post.id, Post.preloads())
    broadcast({1, updated_post}, :post_updated)
    updated_post
  end

  @doc """
  Creates a comment for a post.

  ## Examples

      iex> create_comment(attrs)
      {:ok, %Comment{}}

      iex> create_comment(attrs)
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  defp convert_downvote_to_upvote(post, user) do
    Multi.new()
    |> Multi.delete(:downvote, get_downvote!(post, user))
    |> Multi.insert(:upvote, fn _ ->
      %Upvote{}
      |> Upvote.changeset(%{post_id: post.id, user_id: user.id})
    end)
    |> Multi.update(
      :post,
      Post.changeset(post, %{
        downvote_count: post.downvote_count - 1,
        upvote_count: post.upvote_count + 1
      })
    )
    |> Repo.transaction()
  end

  defp convert_upvote_to_downvote(post, user) do
    Multi.new()
    |> Multi.delete(:upvote, get_upvote!(post, user))
    |> Multi.insert(:downvote, fn _ ->
      %Downvote{}
      |> Downvote.changeset(%{post_id: post.id, user_id: user.id})
    end)
    |> Multi.update(
      :post,
      Post.changeset(post, %{
        downvote_count: post.downvote_count + 1,
        upvote_count: post.upvote_count - 1
      })
    )
    |> Repo.transaction()
  end

  @topic "posts"

  @doc """
  Subscribes to the posts topic.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(Educatium.PubSub, @topic)
  end

  defp broadcast({1, post}, event) do
    Phoenix.PubSub.broadcast(Educatium.PubSub, @topic, {event, post})
    {:ok, post}
  end

  alias Educatium.Feed.Announcement

  @doc """
  Returns the list of announcements.

  ## Examples

      iex> list_announcements()
      [%Announcement{}, ...]

  """
  def list_announcements do
    Repo.all(Announcement)
  end

  @doc """
  Gets a single announcement.

  Raises `Ecto.NoResultsError` if the Announcement does not exist.

  ## Examples

      iex> get_announcement!(123)
      %Announcement{}

      iex> get_announcement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_announcement!(id, preloads \\ []) do
    Repo.get!(Announcement, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a announcement with its respective post.
  Unlike a resource, an announcement is always tied to a post.

  ## Examples

      iex> create_announcement(%{field: value})
      {:ok, %Announcement{}}

      iex> create_announcement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_announcement(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:post, fn _ ->
      %Post{}
      |> Post.changeset(%{type: :announcement})
    end)
    |> Multi.insert(:announcement, fn %{post: post} ->
      %Announcement{}
      |> Announcement.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:post, post)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{announcement: announcement, post: post}} ->
        broadcast({1, post}, :post_created)
        {:ok, announcement}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a announcement.

  ## Examples

      iex> update_announcement(announcement, %{field: new_value})
      {:ok, %Announcement{}}

      iex> update_announcement(announcement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_announcement(%Announcement{} = announcement, attrs) do
    announcement
    |> Announcement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a announcement.

  ## Examples

      iex> delete_announcement(announcement)
      {:ok, %Announcement{}}

      iex> delete_announcement(announcement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_announcement(%Announcement{} = announcement) do
    Repo.delete(announcement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking announcement changes.

  ## Examples

      iex> change_announcement(announcement)
      %Ecto.Changeset{data: %Announcement{}}

  """
  def change_announcement(%Announcement{} = announcement, attrs \\ %{}) do
    Announcement.changeset(announcement, attrs)
  end
end
