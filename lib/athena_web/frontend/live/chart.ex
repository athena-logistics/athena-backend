defmodule AthenaWeb.Chart do
  @moduledoc false

  use AthenaWeb, :component

  attr :dom_id, :string, required: true
  attr :config, :any, required: true

  def chart(assigns) do
    ~H"""
    <div>
      <%= content_tag(
        :div,
        "",
        id: @dom_id <> "_hook",
        "phx-hook": "Chart",
        hidden: true,
        data: [
          chart:
            @config
            |> Map.put(:id, @dom_id <> "_chart")
            |> Map.update(:chart, %{height: "50%"}, &Map.put_new(&1, :height, "50%"))
            |> Jason.encode!()
        ]
      ) %>
      <div phx-update="ignore" id={"#{@dom_id}_ignore"} class="position-relative chart-container">
        <canvas id={"#{@dom_id}_chart"} />
      </div>
    </div>
    """
  end
end
