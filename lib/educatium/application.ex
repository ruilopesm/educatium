defmodule Educatium.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EducatiumWeb.Telemetry,
      Educatium.Repo,
      {DNSCluster, query: Application.get_env(:educatium, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Educatium.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Educatium.Finch},
      # Start a worker by calling: Educatium.Worker.start_link(arg)
      # {Educatium.Worker, arg},
      # Start to serve requests, typically the last entry
      EducatiumWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Educatium.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EducatiumWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
