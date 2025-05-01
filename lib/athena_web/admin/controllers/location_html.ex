defmodule AthenaWeb.Admin.LocationHTML do
  @moduledoc false

  use AthenaWeb, :html

  embed_templates "location/*"

  defp location_qr_code(location, format)

  defp location_qr_code(location, :svg) do
    ~p"/vendor/locations/#{location}"
    |> url()
    |> EQRCode.encode()
    |> EQRCode.svg(width: 200, background_color: "#FFF")
  end

  defp location_qr_code(location, :png) do
    ~p"/vendor/locations/#{location}"
    |> url()
    |> EQRCode.encode()
    |> EQRCode.png(width: 2_000)
  end
end
