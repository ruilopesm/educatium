defmodule Educatium.Repo do
  use Ecto.Repo,
    otp_app: :educatium,
    adapter: Ecto.Adapters.Postgres
end
