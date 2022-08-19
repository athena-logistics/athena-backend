defmodule Athena.Repo do
  use Ecto.Repo,
    otp_app: :athena_logistics,
    adapter: Ecto.Adapters.Postgres
end
