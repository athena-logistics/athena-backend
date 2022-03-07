defmodule AthenaWeb.Schema.Helpers do
  @moduledoc """
  Helpers
  """

  alias Absinthe.Relay.Connection
  alias Athena.Repo
  alias Ecto.Changeset

  @spec connection_from_query(
          query,
          args :: map,
          list_fn :: (query -> [row]),
          count_fn :: (query -> row) | nil
        ) ::
          {:error, term()}
          | {:ok, Connection.t()}
        when query: Ecto.Queryable.t(),
             row: any
  def connection_from_query(
        query,
        args,
        list_fn \\ &Repo.all/1,
        count_fn \\ &Repo.aggregate(&1, :count)
      )
      when is_function(list_fn, 1) and (is_function(count_fn, 1) or is_nil(count_fn)) do
    Connection.from_query(
      query,
      list_fn,
      Map.take(args, [:first, :last, :before, :after]),
      case count_fn do
        nil -> []
        fun when is_function(fun, 1) -> [count: count_fn.(query)]
      end
    )
  end

  @spec many_dataloader :: Absinthe.Resolution.Helpers.dataloader_key_fun()
  def many_dataloader do
    fn parent, args, resolution ->
      parent
      |> Ecto.assoc(resolution.definition.schema_node.identifier)
      |> connection_from_query(args)
    end
  end

  defmacro payload_fields(output_type) do
    quote location: :keep do
      field(:successful, non_null(:boolean),
        description: "Indicates if the mutation completed successfully or not. "
      )

      field(:messages, list_of(:validation_message),
        description: "A list of failed validations. May be blank or null if mutation succeeded."
      )

      field(:result, unquote(output_type),
        description:
          "The object created/updated/deleted by the mutation. May be null if mutation failed."
      )
    end
  end

  @dialyzer {:no_contracts, {:changeset_result, 1}}
  @spec changeset_result(result :: {:ok, term}) :: {:ok, term}
  @spec changeset_result(result :: {:error, Ecto.Changeset.t()}) :: {:ok, Ecto.Changeset.t()}
  @spec changeset_result(result :: {:error, term}) :: {:error, term}
  def changeset_result({:ok, _result} = result), do: result
  def changeset_result({:error, %Changeset{} = changeset}), do: {:ok, changeset}
  def changeset_result({:error, _error} = result), do: result
end
