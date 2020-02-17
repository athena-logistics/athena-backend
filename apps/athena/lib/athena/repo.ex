defmodule Athena.Repo do
  use Ecto.Repo,
    otp_app: :athena,
    adapter: Ecto.Adapters.Postgres
end
