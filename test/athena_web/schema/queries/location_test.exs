defmodule AthenaWeb.Schema.Query.LocationTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Location($id: ID!) {
    location(id: $id) {
      id
    }
  }
  """

  test "gets location by id" do
    location = location()

    node_id = global_id!(:location, location.id)

    assert result = run!(@query, variables: %{"id" => location.id})

    assert %{data: %{"location" => %{"id" => ^node_id}}} = result
  end
end
