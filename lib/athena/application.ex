defmodule Athena.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        {Cluster.Supervisor,
         [
           Application.get_env(:libcluster, :topologies, []),
           [name: Athena.Cluster.ClusterSupervisor]
         ]},
        Athena.Telemetry,
        Athena.Repo,
        {Phoenix.PubSub, name: Athena.PubSub},
        # Start the endpoint when the application starts
        AthenaWeb.Endpoint
        # Starts a worker by calling: AthenaWeb.Worker.start_link(arg)
        # {AthenaWeb.Worker, arg},
      ],
      strategy: :one_for_one,
      name: Athena.Supervisor
    )
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AthenaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
