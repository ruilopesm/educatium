defmodule Educatium.ResourcesTest do
  use Educatium.DataCase

  alias Educatium.Resources

  describe "resources" do
    import Educatium.ResourcesFixtures

    alias Educatium.Resources.Resource

    @invalid_attrs %{
      type: nil,
      date: nil,
      description: nil,
      title: nil,
      published: nil,
      visibility: nil
    }

    test "list_resources/0 returns all resources" do
      resource = resource_fixture()
      assert Resources.list_resources() == [resource]
    end

    test "get_resource!/1 returns the resource with given id" do
      resource = resource_fixture()
      assert Resources.get_resource!(resource.id) == resource
    end

    test "create_resource/1 with valid data creates a resource" do
      valid_attrs = %{
        type: :book,
        date: ~D[2024-05-28],
        description: "some description",
        title: "some title",
        published: ~N[2024-05-28 16:32:00],
        visibility: :protected
      }

      assert {:ok, %Resource{} = resource} = Resources.create_resource(valid_attrs)
      assert resource.type == :book
      assert resource.date == ~D[2024-05-28]
      assert resource.description == "some description"
      assert resource.title == "some title"
      assert resource.published == ~N[2024-05-28 16:32:00]
      assert resource.visibility == :protected
    end

    test "create_resource/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_resource(@invalid_attrs)
    end

    test "update_resource/2 with valid data updates the resource" do
      resource = resource_fixture()

      update_attrs = %{
        type: :article,
        date: ~D[2024-05-29],
        description: "some updated description",
        title: "some updated title",
        published: ~N[2024-05-29 16:32:00],
        visibility: :private
      }

      assert {:ok, %Resource{} = resource} = Resources.update_resource(resource, update_attrs)
      assert resource.type == :article
      assert resource.date == ~D[2024-05-29]
      assert resource.description == "some updated description"
      assert resource.title == "some updated title"
      assert resource.published == ~N[2024-05-29 16:32:00]
      assert resource.visibility == :private
    end

    test "update_resource/2 with invalid data returns error changeset" do
      resource = resource_fixture()
      assert {:error, %Ecto.Changeset{}} = Resources.update_resource(resource, @invalid_attrs)
      assert resource == Resources.get_resource!(resource.id)
    end

    test "delete_resource/1 deletes the resource" do
      resource = resource_fixture()
      assert {:ok, %Resource{}} = Resources.delete_resource(resource)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_resource!(resource.id) end
    end

    test "change_resource/1 returns a resource changeset" do
      resource = resource_fixture()
      assert %Ecto.Changeset{} = Resources.change_resource(resource)
    end
  end
end
