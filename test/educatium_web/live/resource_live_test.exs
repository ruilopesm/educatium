defmodule EducatiumWeb.ResourceLiveTest do
  use EducatiumWeb.ConnCase

  import Educatium.ResourcesFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{
    type: :book,
    date: "2024-05-28",
    description: "some description",
    title: "some title",
    published: "2024-05-28T16:32:00",
    visibility: :protected
  }
  @update_attrs %{
    type: :article,
    date: "2024-05-29",
    description: "some updated description",
    title: "some updated title",
    published: "2024-05-29T16:32:00",
    visibility: :private
  }
  @invalid_attrs %{
    type: nil,
    date: nil,
    description: nil,
    title: nil,
    published: nil,
    visibility: nil
  }

  defp create_resource(_) do
    resource = resource_fixture()
    %{resource: resource}
  end

  describe "Index" do
    setup [:create_resource]

    test "lists all resources", %{conn: conn, resource: resource} do
      {:ok, _index_live, html} = live(conn, ~p"/resources")

      assert html =~ "Listing Resources"
      assert html =~ resource.description
    end

    test "saves new resource", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/resources")

      assert index_live |> element("a", "New Resource") |> render_click() =~
               "New Resource"

      assert_patch(index_live, ~p"/resources/new")

      assert index_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#resource-form", resource: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/resources")

      html = render(index_live)
      assert html =~ "Resource created successfully"
      assert html =~ "some description"
    end

    test "updates resource in listing", %{conn: conn, resource: resource} do
      {:ok, index_live, _html} = live(conn, ~p"/resources")

      assert index_live |> element("#resources-#{resource.id} a", "Edit") |> render_click() =~
               "Edit Resource"

      assert_patch(index_live, ~p"/resources/#{resource}/edit")

      assert index_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#resource-form", resource: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/resources")

      html = render(index_live)
      assert html =~ "Resource updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes resource in listing", %{conn: conn, resource: resource} do
      {:ok, index_live, _html} = live(conn, ~p"/resources")

      assert index_live |> element("#resources-#{resource.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#resources-#{resource.id}")
    end
  end

  describe "Show" do
    setup [:create_resource]

    test "displays resource", %{conn: conn, resource: resource} do
      {:ok, _show_live, html} = live(conn, ~p"/resources/#{resource}")

      assert html =~ "Show Resource"
      assert html =~ resource.description
    end

    test "updates resource within modal", %{conn: conn, resource: resource} do
      {:ok, show_live, _html} = live(conn, ~p"/resources/#{resource}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Resource"

      assert_patch(show_live, ~p"/resources/#{resource}/show/edit")

      assert show_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#resource-form", resource: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/resources/#{resource}")

      html = render(show_live)
      assert html =~ "Resource updated successfully"
      assert html =~ "some updated description"
    end
  end
end
