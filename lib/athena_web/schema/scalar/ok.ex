defmodule AthenaWeb.Schema.Scalar.Ok do
  @moduledoc """
  Ok Enum for API
  """

  use Absinthe.Schema.Notation

  @desc """
  Enum to suggest that action was executed successfully, no details are
  provided.
  """
  enum(:ok, values: [:ok])
end
