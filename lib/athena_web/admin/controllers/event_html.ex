defmodule AthenaWeb.Admin.EventHTML do
  @moduledoc false

  use AthenaWeb, :html

  embed_templates "event/*"

  defp event_qr_code(event, format)

  defp event_qr_code(event, :svg) do
    ~p"/logistics/events/#{event}/overview"
    |> url()
    |> EQRCode.encode()
    |> EQRCode.svg(width: 200, background_color: "#FFF")
  end

  defp event_qr_code(event, :png) do
    ~p"/logistics/events/#{event}/overview"
    |> url()
    |> EQRCode.encode()
    |> EQRCode.png(width: 2_000)
  end
end
