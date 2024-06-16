defmodule EducatiumWeb.ResourceLive.Components.FileSystem do
  @moduledoc false
  use EducatiumWeb, :html

  alias Educatium.Resources
  alias Educatium.Resources.Directory
  alias Educatium.Uploaders.File

  attr :directory, Directory, required: true

  def file_system(assigns) do
    ~H"""
    <div class="mt-10 flow-root">
      <div class="inline-block min-w-full py-2 align-middle">
        <div class="overflow-hidden ring-1 ring-black ring-opacity-5">
          <div class="min-w-full divide-y divide-gray-300">
            <div class="relative flex items-center justify-center bg-gray-50">
              <!-- Arrow Container -->
              <div class="absolute left-0 whitespace-nowrap py-4 pr-4 pl-3 text-left text-sm font-medium sm:pr-6">
                <%= if @directory.directory_id do %>
                  <div
                    phx-click="load-directory"
                    phx-value-dir_id={@directory.directory_id}
                    class="cursor-pointer hover:text-orange-600 hover:underline"
                  >
                    <.icon name="hero-arrow-uturn-left" class="size-5 ml-4" />
                  </div>
                <% end %>
              </div>
              <!-- Title Container -->
              <div class="flex-1 py-3.5 pr-3 pl-4 text-center text-sm font-semibold tracking-wide text-gray-900 sm:pl-6">
                <%= build_directory_path(@directory.id) %>
              </div>
            </div>
            <table class="min-w-full divide-y divide-gray-300">
              <tbody class="divide-y divide-gray-200 bg-white">
                <!-- Directories -->
                <%= for dir <- @directory.subdirectories do %>
                  <tr>
                    <td class="relative whitespace-nowrap py-4 pr-4 pl-3 text-left text-sm font-medium sm:pr-6">
                      <.icon name="hero-folder" class="size-5 ml-4" />
                    </td>
                    <td class="whitespace-nowrap py-4 pr-3 pl-4 text-sm font-medium text-gray-900 sm:pl-6">
                      <div
                        phx-click="load-directory"
                        phx-value-dir_id={dir.id}
                        class="cursor-pointer hover:text-orange-600 hover:underline"
                      >
                        <%= dir.name %>
                      </div>
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      <%= directory_n_items(dir.id) %>
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      <%= relative_datetime(dir.inserted_at) %>
                    </td>
                    <td class="relative whitespace-nowrap py-4 pr-4 pl-3 text-right text-sm font-medium sm:pr-6">
                      <.link
                        href={~p"/directories/#{dir.id}"}
                        class="cursor-pointer hover:text-orange-600 hover:underline"
                      >
                        <.icon name="hero-arrow-down-tray" class="size-5 mr-4" />
                      </.link>
                    </td>
                  </tr>
                <% end %>
                <!-- Files -->
                <%= for file <- @directory.files do %>
                  <tr>
                    <td class="relative whitespace-nowrap py-4 pr-4 pl-3 text-left text-sm font-medium sm:pr-6">
                      <.icon name="hero-document" class="size-5 ml-4" />
                    </td>
                    <td class="whitespace-nowrap py-4 pr-3 pl-4 text-sm font-medium text-gray-900 sm:pl-6">
                      <%= file.name %>
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      <%= Size.humanize!(file.size) %>
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      <%= relative_datetime(file.inserted_at) %>
                    </td>
                    <td class="relative whitespace-nowrap py-4 pr-4 pl-3 text-right text-sm font-medium sm:pr-6">
                      <.link
                        href={get_file_path(file.id)}
                        class="cursor-pointer hover:text-orange-600 hover:underline"
                      >
                        <.icon name="hero-arrow-down-tray" class="size-5 mr-4" />
                      </.link>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp build_directory_path(directory_id) do
    directory = Resources.get_directory!(directory_id)

    if is_nil(directory.directory_id) do
      "#{directory.name}"
    else
      build_directory_path(directory.directory_id) <> "/#{directory.name}"
    end
  end

  defp directory_n_items(directory_id) do
    directory = Resources.get_directory!(directory_id, [:files, :subdirectories])
    n_items = Enum.count(directory.files) + Enum.count(directory.subdirectories)

    if n_items == 1, do: "#{n_items} item", else: "#{n_items} items"
  end

  defp get_file_path(file_id) do
    file = Resources.get_file!(file_id)
    File.url({file.file, file}, :original)
  end
end
