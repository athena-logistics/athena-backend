defmodule Athena.Cluster.Application do
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
           [name: Athena.Clister.ClusterSupervisor]
         ]}
      ],
      strategy: :one_for_one,
      name: Athena.Cluster.Supervisor
    )
  end
end
