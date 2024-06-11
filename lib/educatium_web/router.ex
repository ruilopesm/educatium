defmodule EducatiumWeb.Router do
  use EducatiumWeb, :router

  alias EducatiumWeb.Gettext

  import EducatiumWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EducatiumWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EducatiumWeb.Plugs.SetLocale, gettext: Gettext, default_locale: Gettext.default_locale()
    plug :fetch_current_user
  end

  pipeline :active, do: plug(EducatiumWeb.Plugs.ActiveUser)

  ## Normal routes

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:educatium, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EducatiumWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", EducatiumWeb do
    pipe_through :browser

    live "/users/reset_password", UserForgotPasswordLive, :new
    live "/users/reset_password/:token", UserResetPasswordLive, :edit
    
    pipe_through :redirect_if_user_is_authenticated

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{EducatiumWeb.UserAuth, :mount_current_user}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
    end

    post "/users/log_in", UserSessionController, :create

    get "/auth/:provider", OAuthController, :request
    get "/auth/:provider/callback", OAuthController, :callback
  end

  scope "/", EducatiumWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{EducatiumWeb.UserAuth, :ensure_authenticated}] do
      live "/users/setup", UserSetupLive, :edit

      pipe_through :active

      live "/", HomeLive
      live "/resources", ResourceLive.Index, :index

      live "/resources/new", ResourceLive.Index, :new
      live "/resources/:id/edit", ResourceLive.Index, :edit

      live "/resources/:id", ResourceLive.Show, :show
      live "/resources/:id/show/edit", ResourceLive.Show, :edit

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", EducatiumWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{EducatiumWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
