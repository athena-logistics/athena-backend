defmodule Athena.Telemetry do
  @moduledoc """
  API Telemetry
  """

  use Supervisor

  import Telemetry.Metrics

  @spec start_link(args :: Keyword.t()) :: Supervisor.on_start()
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_arg) do
    Supervisor.init(
      [
        # Telemetry poller will execute the given period measurements
        # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
        {:telemetry_poller, measurements: periodic_measurements(), period: 1_000}
        # Add reporters as children of your supervision tree.
        # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()},
      ],
      strategy: :one_for_one
    )
  end

  @spec metrics :: [struct]
  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.endpoint.stop.duration",
        reporter_options: [
          buckets: power_two_durations(-8, 16)
        ],
        event_name: [:phoenix, :endpoint, :stop],
        measurement: :duration,
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.router_dispatch.stop.duration",
        reporter_options: [
          buckets: power_two_durations(-8, 16)
        ],
        tags: [:route],
        event_name: [:phoenix, :router_dispatch, :stop],
        measurement: :duration,
        unit: {:native, :millisecond}
      ),

      # Database Metrics
      summary("athena.repo.query.total_time", unit: {:native, :millisecond}),
      distribution("athena.repo.query.total_time",
        reporter_options: [
          buckets: power_two_durations(-8, 16)
        ],
        event_name: [:athena_logistics, :repo, :query],
        measurement: :total_time,
        unit: {:native, :millisecond}
      ),
      summary("athena.repo.query.decode_time", unit: {:native, :millisecond}),
      distribution("athena.repo.query.decode_time",
        reporter_options: [
          buckets: power_two_durations(-8, 16)
        ],
        event_name: [:athena_logistics, :repo, :query],
        measurement: :decode_time,
        unit: {:native, :millisecond}
      ),
      summary("athena.repo.query.query_time", unit: {:native, :millisecond}),
      distribution("athena.repo.query.query_time",
        reporter_options: [
          buckets: power_two_durations(-8, 16)
        ],
        event_name: [:athena_logistics, :repo, :query],
        measurement: :query_time,
        unit: {:native, :millisecond}
      ),
      summary("athena.repo.query.queue_time", unit: {:native, :millisecond}),
      distribution("athena.repo.query.queue_time",
        reporter_options: [
          buckets: power_two_durations(-8, 16)
        ],
        event_name: [:athena_logistics, :repo, :query],
        measurement: :queue_time,
        unit: {:native, :millisecond}
      ),
      summary("athena.repo.query.idle_time", unit: {:native, :millisecond}),
      distribution("athena.repo.query.queridle_timey_time",
        reporter_options: [
          buckets: power_two_durations(-8, 16)
        ],
        event_name: [:athena_logistics, :repo, :query],
        measurement: :idle_time,
        unit: {:native, :millisecond}
      ),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      last_value("vm.memory.total", unit: :byte),
      summary("vm.total_run_queue_lengths.total"),
      last_value("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      last_value("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),
      last_value("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements, do: []

  @spec dashboard_metrics :: [map]
  def dashboard_metrics,
    do: Enum.reject(metrics(), &match?(%Telemetry.Metrics.Distribution{}, &1))

  @spec power_two_durations(from :: integer(), to :: integer()) :: [float]
  defp power_two_durations(from, to), do: Enum.map(from..to, &:math.pow(2, &1))
end
