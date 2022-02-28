defmodule AthenaWeb.Redirector do
  @moduledoc """
  Plug to redirect request
  """

  @behaviour Plug

  @impl Plug
  @spec init(Keyword.t()) :: Keyword.t()
  def init(opts), do: opts

  @impl Plug
  @spec call(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def call(conn, opts), do: Phoenix.Controller.redirect(conn, opts)
end
