import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :argon2_elixir, t_cost: 1, m_cost: 8

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :educatium, Educatium.Mailer, adapter: Swoosh.Adapters.Test

config :educatium, Educatium.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "educatium_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :educatium, EducatiumWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "aFNR1dteYMAFyP7nfQRk3LDm5eFafjCaKXcZn35Qs/3s9THxZ/laKbnTyj57M/cW",
  server: false

# In test we don't send emails.
config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Disable swoosh api client as it is only required for production adapters.
  enable_expensive_runtime_checks: true

config :swoosh, :api_client, false

# Print only warnings and errors during test

# Initialize plugs at runtime for faster test compilation
# Enable helpful, but potentially expensive runtime checks
