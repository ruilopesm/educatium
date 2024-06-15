defmodule EducatiumWeb.ResourceControllerTest do
  use EducatiumWeb.ConnCase

  import Educatium.ResourcesFixtures

  alias Educatium.Resources.Resource

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all resources", %{conn: conn} do
      conn = get(conn, ~p"/api/resources")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create resource" do
    test "renders resource when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/resources", resource: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/resources/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/resources", resource: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update resource" do
    setup [:create_resource]

    test "renders resource when data is valid", %{conn: conn, resource: %Resource{id: id} = resource} do
      conn = put(conn, ~p"/api/resources/#{resource}", resource: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/resources/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, resource: resource} do
      conn = put(conn, ~p"/api/resources/#{resource}", resource: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete resource" do
    setup [:create_resource]

    test "deletes chosen resource", %{conn: conn, resource: resource} do
      conn = delete(conn, ~p"/api/resources/#{resource}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/resources/#{resource}")
      end
    end
  end

  defp create_resource(_) do
    resource = resource_fixture()
    %{resource: resource}
  end
end
