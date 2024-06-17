defmodule EducatiumWeb.Admin.AnnouncementLiveTest do
  use EducatiumWeb.ConnCase

  import Phoenix.LiveViewTest
  import Educatium.FeedFixtures

  @create_attrs %{title: "some title", body: "some body"}
  @update_attrs %{title: "some updated title", body: "some updated body"}
  @invalid_attrs %{title: nil, body: nil}

  defp create_announcement(_) do
    announcement = announcement_fixture()
    %{announcement: announcement}
  end

  describe "Index" do
    setup [:create_announcement]

    test "lists all announcements", %{conn: conn, announcement: announcement} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/announcements")

      assert html =~ "Listing Announcements"
      assert html =~ announcement.title
    end

    test "saves new announcement", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/announcements")

      assert index_live |> element("a", "New Announcement") |> render_click() =~
               "New Announcement"

      assert_patch(index_live, ~p"/admin/announcements/new")

      assert index_live
             |> form("#announcement-form", announcement: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#announcement-form", announcement: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/announcements")

      html = render(index_live)
      assert html =~ "Announcement created successfully"
      assert html =~ "some title"
    end

    test "updates announcement in listing", %{conn: conn, announcement: announcement} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/announcements")

      assert index_live
             |> element("#announcements-#{announcement.id} a", "Edit")
             |> render_click() =~
               "Edit Announcement"

      assert_patch(index_live, ~p"/admin/announcements/#{announcement}/edit")

      assert index_live
             |> form("#announcement-form", announcement: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#announcement-form", announcement: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/announcements")

      html = render(index_live)
      assert html =~ "Announcement updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes announcement in listing", %{conn: conn, announcement: announcement} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/announcements")

      assert index_live
             |> element("#announcements-#{announcement.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#announcements-#{announcement.id}")
    end
  end

  describe "Show" do
    setup [:create_announcement]

    test "displays announcement", %{conn: conn, announcement: announcement} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/announcements/#{announcement}")

      assert html =~ "Show Announcement"
      assert html =~ announcement.title
    end

    test "updates announcement within modal", %{conn: conn, announcement: announcement} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/announcements/#{announcement}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Announcement"

      assert_patch(show_live, ~p"/admin/announcements/#{announcement}/show/edit")

      assert show_live
             |> form("#announcement-form", announcement: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#announcement-form", announcement: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/announcements/#{announcement}")

      html = render(show_live)
      assert html =~ "Announcement updated successfully"
      assert html =~ "some updated title"
    end
  end
end
