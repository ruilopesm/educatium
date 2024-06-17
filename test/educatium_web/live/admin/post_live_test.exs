defmodule EducatiumWeb.Admin.PostLiveTest do
  use EducatiumWeb.ConnCase

  import Phoenix.LiveViewTest
  import Educatium.FeedFixtures

  @create_attrs %{
    type: :resource,
    view_count: 42,
    upvote_count: 42,
    downvote_count: 42,
    comment_count: 42
  }
  @update_attrs %{
    type: :resource,
    view_count: 43,
    upvote_count: 43,
    downvote_count: 43,
    comment_count: 43
  }
  @invalid_attrs %{
    type: nil,
    view_count: nil,
    upvote_count: nil,
    downvote_count: nil,
    comment_count: nil
  }

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end

  describe "Index" do
    setup [:create_post]

    test "lists all posts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/posts")

      assert html =~ "Listing Posts"
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/posts")

      assert index_live |> element("a", "New Post") |> render_click() =~
               "New Post"

      assert_patch(index_live, ~p"/admin/posts/new")

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#post-form", post: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/posts")

      html = render(index_live)
      assert html =~ "Post created successfully"
    end

    test "updates post in listing", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/posts")

      assert index_live |> element("#posts-#{post.id} a", "Edit") |> render_click() =~
               "Edit Post"

      assert_patch(index_live, ~p"/admin/posts/#{post}/edit")

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#post-form", post: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/posts")

      html = render(index_live)
      assert html =~ "Post updated successfully"
    end

    test "deletes post in listing", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/posts")

      assert index_live |> element("#posts-#{post.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#posts-#{post.id}")
    end
  end

  describe "Show" do
    setup [:create_post]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/posts/#{post}")

      assert html =~ "Show Post"
    end

    test "updates post within modal", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/posts/#{post}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Post"

      assert_patch(show_live, ~p"/admin/posts/#{post}/show/edit")

      assert show_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#post-form", post: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/posts/#{post}")

      html = render(show_live)
      assert html =~ "Post updated successfully"
    end
  end
end
