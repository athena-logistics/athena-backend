defmodule AthenaWeb.GraphqlWSSocket do
  @moduledoc false

  use Absinthe.GraphqlWS.Socket, schema: AthenaWeb.Schema
end
