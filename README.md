# Athena

![.github/workflows/elixir.yml](https://github.com/maennchen/athena/workflows/.github/workflows/elixir.yml/badge.svg)

:beer::tropical_drink::wine_glass: Event Logistics Management

## Development

To start your Phoenix server:

  * Install Elixir / Node / Erlang using [`asdf`](https://asdf-vm.com/) as specified in `.tool-versions`
  * Start Local Postgres for example using Docker
```bash
docker run \
  --restart always \                                                                  
  --name postgres \
  -v /usr/local/opt/postgres:/var/lib/postgresql/data \
  -p 5432:5432 \
  -d \
  -e POSTGRES_PASSWORD="" \
  -e POSTGRES_USER="root" \
  -e POSTGRES_HOST_AUTH_METHOD="trust" \
  postgres:latest
```
  * Setup Environment Variables with `export DATABASE_USER="root" DATABASE_PASSWORD="" DATABASE_HOST="127.0.0.1"`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install --prefix assets`
  * Create Database with `mix ecto.create`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
