defmodule AthenaWeb.Schema.Query.Node.EventTest do
  @moduledoc false

  use Athena.DataCase
  use AthenaWeb.GraphQLCase

  import Athena.Fixture

  @query """
  query Node($id: ID!) {
    node(id: $id) {
      id
      ... on Event {
        name
        insertedAt
        updatedAt
      }
    }
  }
  """

  test "gets event by id" do
    event = event(name: "Awesome Gathering")

    node_id = global_id!(:event, event.id)

    assert result = run!(@query, variables: %{"id" => node_id})

    assert %{
             data: %{
               "node" => %{
                 "id" => ^node_id,
                 "name" => "Awesome Gathering",
                 "insertedAt" => _inserted_at,
                 "updatedAt" => _updated_at
               }
             }
           } = result
  end
end
