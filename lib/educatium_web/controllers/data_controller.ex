defmodule EducatiumWeb.DataController do
  use EducatiumWeb, :controller

  alias Educatium.Repo
  alias Educatium.Accounts.User
  alias Educatium.Feed.{Announcement, Comment, Downvote, Post, Upvote}
  alias Educatium.Resources.{Bookmark, Directory, File, Resource, Tag}

  def export(conn, _params) do
    users = gather_users()
    announcements = gather_announcements()
    comments = gather_comments()
    downvotes = gather_downvotes()
    posts = gather_posts()
    upvotes = gather_upvotes()
    bookmarks = gather_bookmarks()
    directories = gather_directories()
    files = gather_files()
    resources = gather_resources()
    tags = gather_tags()

    data = %{
      users: users,
      announcements: announcements,
      comments: comments,
      downvotes: downvotes,
      posts: posts,
      upvotes: upvotes,
      bookmarks: bookmarks,
      directories: directories,
      files: files,
      resources: resources,
      tags: tags
    }

    {:ok, file} = Temp.path("export.json")
    Elixir.File.write!(file, Jason.encode!(data))

    send_download(conn, {:file, file}, filename: "export.json")
  end

  defp gather_users do
    User
    |> Repo.all()
    |> Enum.map(&user_to_map/1)
  end

  defp gather_announcements do
    Announcement
    |> Repo.all()
    |> Enum.map(&announcement_to_map/1)
  end

  defp gather_comments do
    Comment
    |> Repo.all()
    |> Enum.map(&comment_to_map/1)
  end

  defp gather_downvotes do
    Downvote
    |> Repo.all()
    |> Enum.map(&downvote_to_map/1)
  end

  defp gather_posts do
    Post
    |> Repo.all()
    |> Enum.map(&post_to_map/1)
  end

  defp gather_upvotes do
    Upvote
    |> Repo.all()
    |> Enum.map(&upvote_to_map/1)
  end

  defp gather_bookmarks do
    Bookmark
    |> Repo.all()
    |> Enum.map(&bookmark_to_map/1)
  end

  defp gather_directories do
    Directory
    |> Repo.all()
    |> Enum.map(&directory_to_map/1)
  end

  defp gather_files do
    File
    |> Repo.all()
    |> Enum.map(&file_to_map/1)
  end

  defp gather_resources do
    Resource
    |> Repo.all()
    |> Enum.map(&resource_to_map/1)
  end

  defp gather_tags do
    Tag
    |> Repo.all()
    |> Enum.map(&tag_to_map/1)
  end

  defp user_to_map(%User{} = user) do
    %{
      email: user.email,
      avatar: user.avatar,
      handle: user.handle,
      first_name: user.first_name,
      last_name: user.last_name,
      course: user.course,
      university: user.university,
      role: user.role,
      active: user.active
    }
  end

  defp announcement_to_map(%Announcement{} = announcement) do
    %{
      title: announcement.title,
      body: announcement.body,
      user_id: announcement.user_id,
      post_id: announcement.post_id
    }
  end

  defp comment_to_map(%Comment{} = comment) do
    %{
      body: comment.body,
      user_id: comment.user_id,
      post_id: comment.post_id
    }
  end

  defp downvote_to_map(%Downvote{} = downvote) do
    %{
      user_id: downvote.user_id,
      post_id: downvote.post_id
    }
  end

  defp post_to_map(%Post{} = post) do
    %{
      view_count: post.view_count,
      upvote_count: post.upvote_count,
      downvote_count: post.downvote_count,
      comment_count: post.comment_count,
      type: post.type
    }
  end

  defp upvote_to_map(%Upvote{} = upvote) do
    %{
      user_id: upvote.user_id,
      post_id: upvote.post_id
    }
  end

  defp bookmark_to_map(%Bookmark{} = bookmark) do
    %{
      user_id: bookmark.user_id,
      resource_id: bookmark.resource_id
    }
  end

  defp directory_to_map(%Directory{} = directory) do
    %{
      name: directory.name
    }
  end

  defp file_to_map(%File{} = file) do
    %{
      name: file.name,
      size: file.size,
      resource_id: file.resource_id,
      directory_id: file.directory_id
    }
  end

  defp resource_to_map(%Resource{} = resource) do
    %{
      title: resource.title,
      description: resource.description,
      type: resource.type,
      date: resource.date,
      visibility: resource.visibility,
      user_id: resource.user_id,
      post_id: resource.post_id
    }
  end

  defp tag_to_map(%Tag{} = tag) do
    %{
      name: tag.name,
      color: tag.color
    }
  end
end
