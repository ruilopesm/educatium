defmodule EducatiumWeb.Admin.ResourceLiveTest do
  use EducatiumWeb.ConnCase

  import Phoenix.LiveViewTest
  import Educatium.ResourcesFixtures

  @create_attrs %{
    type: :book,
    description: "some description",
    title: "some title",
    visibility: :public
  }
  @update_attrs %{
    type: :article,
    description: "some updated description",
    title: "some updated title",
    visibility: :private
  }
  @invalid_attrs %{type: nil, description: nil, title: nil, visibility: nil}

  defp create_resource(_) do
    resource = resource_fixture()
    %{resource: resource}
  end

  describe "Index" do
    setup [:create_resource]

    test "lists all resources", %{conn: conn, resource: resource} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/resources")

      assert html =~ "Listing Resources"
      assert html =~ resource.description
    end

    test "saves new resource", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/resources")

      assert index_live |> element("a", "New Resource") |> render_click() =~
               "New Resource"

      assert_patch(index_live, ~p"/admin/resources/new")

      assert index_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#resource-form", resource: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/resources")

      html = render(index_live)
      assert html =~ "Resource created successfully"
      assert html =~ "some description"
    end

    test "updates resource in listing", %{conn: conn, resource: resource} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/resources")

      assert index_live |> element("#resources-#{resource.id} a", "Edit") |> render_click() =~
               "Edit Resource"

      assert_patch(index_live, ~p"/admin/resources/#{resource}/edit")

      assert index_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#resource-form", resource: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/resources")

      html = render(index_live)
      assert html =~ "Resource updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes resource in listing", %{conn: conn, resource: resource} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/resources")

      assert index_live |> element("#resources-#{resource.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#resources-#{resource.id}")
    end
  end

  describe "Show" do
    setup [:create_resource]

    test "displays resource", %{conn: conn, resource: resource} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/resources/#{resource}")

      assert html =~ "Show Resource"
      assert html =~ resource.description
    end

    test "updates resource within modal", %{conn: conn, resource: resource} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/resources/#{resource}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Resource"

      assert_patch(show_live, ~p"/admin/resources/#{resource}/show/edit")

      assert show_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#resource-form", resource: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/resources/#{resource}")

      html = render(show_live)
      assert html =~ "Resource updated successfully"
      assert html =~ "some updated description"
    end
  end
end
