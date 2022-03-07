defmodule AthenaWeb.Schema.Query.EventTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Event($id: ID!) {
    event(id: $id) {
      id
    }
  }
  """

  test "gets event by id" do
    event = event()

    node_id = global_id!(:event, event.id)

    assert result = run!(@query, variables: %{"id" => event.id})

    assert %{data: %{"event" => %{"id" => ^node_id}}} = result
  end
end
