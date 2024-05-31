defmodule EducatiumWeb.Core.Oauth do
  use Phoenix.Component
  use EducatiumWeb, :live_view

  def google(assigns) do
    ~H"""
    <.link
      href={@login_uri}
      class="px-4 py-2 border flex gap-2 border-slate-200 dark:border-slate-700 rounded-lg text-slate-700 dark:text-slate-200 hover:border-slate-400 dark:hover:border-slate-500 hover:text-slate-900 dark:hover:text-slate-300 hover:shadow transition duration-150"
    >
      <img
        class="w-6 h-6"
        src="https://www.svgrepo.com/show/475656/google-color.svg"
        loading="lazy"
        alt="google logo"
      />
      <span class="text-black">Login with Google</span>
    </.link>
    """
  end
end
