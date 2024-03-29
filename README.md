<img align="right" src="./assets/static/images/logo.png" width="300px">

# Athena

[![Main Branch](https://github.com/athena-logistics/athena-backend/actions/workflows/branch_main.yml/badge.svg)](https://github.com/athena-logistics/athena-backend/actions/workflows/branch_main.yml)
[![Coverage Status](https://coveralls.io/repos/github/athena-logistics/athena-backend/badge.svg?branch=main)](https://coveralls.io/github/athena-logistics/athena-backend?branch=main)
[![License](https://img.shields.io/github/license/athena-logistics/athena-backend.svg)](https://github.com/athena-logistics/athena-backend/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/athena-logistics/athena-backend.svg)](https://github.com/athena-logistics/athena-backend/commits/master)

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
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
