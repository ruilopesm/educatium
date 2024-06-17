defmodule Educatium.FeedTest do
  use Educatium.DataCase

  alias Educatium.Feed

  describe "posts" do
    import Educatium.FeedFixtures

    alias Educatium.Feed.Post

    @invalid_attrs %{type: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Feed.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Feed.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{type: :resource}

      assert {:ok, %Post{} = post} = Feed.create_post(valid_attrs)
      assert post.type == :resource
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Feed.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{type: :resource}

      assert {:ok, %Post{} = post} = Feed.update_post(post, update_attrs)
      assert post.type == :resource
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Feed.update_post(post, @invalid_attrs)
      assert post == Feed.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Feed.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Feed.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Feed.change_post(post)
    end
  end

  describe "announcements" do
    alias Educatium.Feed.Announcement

    import Educatium.FeedFixtures

    @invalid_attrs %{title: nil, body: nil}

    test "list_announcements/0 returns all announcements" do
      announcement = announcement_fixture()
      assert Feed.list_announcements() == [announcement]
    end

    test "get_announcement!/1 returns the announcement with given id" do
      announcement = announcement_fixture()
      assert Feed.get_announcement!(announcement.id) == announcement
    end

    test "create_announcement/1 with valid data creates a announcement" do
      valid_attrs = %{title: "some title", body: "some body"}

      assert {:ok, %Announcement{} = announcement} = Feed.create_announcement(valid_attrs)
      assert announcement.title == "some title"
      assert announcement.body == "some body"
    end

    test "create_announcement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Feed.create_announcement(@invalid_attrs)
    end

    test "update_announcement/2 with valid data updates the announcement" do
      announcement = announcement_fixture()
      update_attrs = %{title: "some updated title", body: "some updated body"}

      assert {:ok, %Announcement{} = announcement} =
               Feed.update_announcement(announcement, update_attrs)

      assert announcement.title == "some updated title"
      assert announcement.body == "some updated body"
    end

    test "update_announcement/2 with invalid data returns error changeset" do
      announcement = announcement_fixture()
      assert {:error, %Ecto.Changeset{}} = Feed.update_announcement(announcement, @invalid_attrs)
      assert announcement == Feed.get_announcement!(announcement.id)
    end

    test "delete_announcement/1 deletes the announcement" do
      announcement = announcement_fixture()
      assert {:ok, %Announcement{}} = Feed.delete_announcement(announcement)
      assert_raise Ecto.NoResultsError, fn -> Feed.get_announcement!(announcement.id) end
    end

    test "change_announcement/1 returns a announcement changeset" do
      announcement = announcement_fixture()
      assert %Ecto.Changeset{} = Feed.change_announcement(announcement)
    end
  end
end
