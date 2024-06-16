defmodule Educatium.MixProject do
  use Mix.Project

  def project do
    [
      app: :educatium,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Educatium.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # core
      {:phoenix, "~> 1.7.12"},
      {:phoenix_live_view, "~> 0.20.2"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:bandit, "~> 1.2"},

      # database
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},

      # auth
      {:ueberauth, "~> 0.6"},
      {:ueberauth_google, "~> 0.10"},

      # frontend
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:tailwind_formatter, "~> 0.3.7", only: [:dev, :test], runtime: false},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},

      # mailer
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},

      # uploads
      {:waffle_ecto, "~> 0.0"},
      {:waffle, "~> 1.1"},

      # files
      {:http_stream, "~> 1.0.0", git: "https://github.com/coders51/http_stream"},
      {:zstream, "~> 0.6"},
      {:size, "~> 0.1.0"},

      # telemetry
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},

      # security
      {:argon2_elixir, "~> 3.0"},

      # testing
      {:floki, ">= 0.30.0", only: :test},
      {:faker, "~> 0.18", only: [:dev, :test]},

      # tools
      {:gettext, "~> 0.20"},
      {:timex, "~> 3.7.11"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:dotenvy, "~> 0.8.0"},
      {:temp, "~> 0.4"},
      {:credo, "~> 1.7.6", only: [:dev, :test], runtime: false},
      {:doctest_formatter, "~> 0.3.0", runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seed"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind educatium", "esbuild educatium"],
      "assets.deploy": [
        "tailwind educatium --minify",
        "esbuild educatium --minify",
        "phx.digest"
      ],
      lint: ["credo -C default"]
    ]
  end
end
