defmodule AthenaWeb.GraphQLCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require GraphQL.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  # use Absinthe.Phoenix.SubscriptionTest, schema: AthenaWeb.Schema

  # import Phoenix.ChannelTest

  alias AthenaWeb.Endpoint
  alias AthenaWeb.Schema

  # @endpoint Endpoint

  using do
    quote do
      use AthenaWeb.ChannelCase

      import unquote(__MODULE__)
      import Absinthe.Phoenix.SubscriptionTest

      use Absinthe.Phoenix.SubscriptionTest, schema: AthenaWeb.Schema

      setup tags do
        {:ok, socket} =
          AthenaWeb.UserSocket
          |> socket(tags[:socket_id] || nil, tags[:socket_assigns] || [])
          |> join_absinthe

        {:ok, socket: socket}
      end
    end
  end

  @spec run(
          input :: String.t() | Absinthe.Language.Source.t() | Absinthe.Language.Document.t(),
          options :: Absinthe.run_opts()
        ) :: Absinthe.run_result()
  def run(input, options \\ []) do
    options = options |> Keyword.put_new(:context, %{}) |> put_in([:context, :pubsub], Endpoint)
    Absinthe.run(input, Schema, options)
  end

  @spec run!(
          input :: String.t() | Absinthe.Language.Source.t() | Absinthe.Language.Document.t(),
          options :: Absinthe.run_opts()
        ) :: Absinthe.result_t()
  def run!(input, options \\ []) do
    options = options |> Keyword.put_new(:context, %{}) |> put_in([:context, :pubsub], Endpoint)
    Absinthe.run!(input, Schema, options)
  end

  defmacro assert_no_error(result) do
    quote location: :keep do
      refute Map.has_key?(unquote(result), :errors)
    end
  end

  @spec global_id(node_type :: String.t(), source_id :: String.t()) :: String.t() | nil
  def global_id(node_type, source_id),
    do: Absinthe.Relay.Node.to_global_id(node_type, source_id, Schema)

  @spec global_id!(node_type :: String.t(), source_id :: String.t()) :: String.t()
  def global_id!(node_type, source_id),
    do: global_id(node_type, source_id) || raise("Invalid ID")

  @spec from_global_id(global_id :: String.t()) :: %{type: atom, id: String.t()}
  def from_global_id(global_id) do
    {:ok, id} = Absinthe.Relay.Node.from_global_id(global_id, Schema)

    id
  end

  @spec add_upload(
          opts :: Absinthe.run_opts(),
          variable_path :: [String.t()],
          file :: Path.t(),
          mime :: String.t(),
          filename :: String.t()
        ) :: Absinthe.run_opts()
  def add_upload(opts, variable_path, file, mime \\ "image/jpeg", filename \\ "test.jpg") do
    upload = %Plug.Upload{
      content_type: mime,
      filename: filename,
      path: file
    }

    identifier = inspect(make_ref())

    opts
    |> add_variable(variable_path, identifier)
    |> add_upload_to_context(identifier, upload)
  end

  @spec add_uploads(
          opts :: Absinthe.run_opts(),
          variable_path :: [String.t()],
          files :: [Path.t()]
        ) :: Absinthe.run_opts()
  def add_uploads(opts, variable_path, files) do
    identifier = inspect(make_ref())

    opts =
      add_variable(opts, variable_path, Enum.map(1..Enum.count(files), &"#{identifier}.#{&1}"))

    files
    |> Enum.zip(1..Enum.count(files))
    |> Enum.reduce(opts, fn {file, index}, acc ->
      add_upload_to_context(acc, "#{identifier}.#{index}", %Plug.Upload{
        content_type: "image/jpeg",
        filename: "test.jpg",
        path: file
      })
    end)
  end

  @spec add_variable(
          opts :: Absinthe.run_opts(),
          variable_path :: [String.t()],
          value :: term
        ) :: Absinthe.run_opts()
  def add_variable(opts, path, value) do
    path =
      for entry <- path, into: [] do
        case entry do
          entry when is_binary(entry) -> Access.key(entry, %{})
        end
      end

    put_in(opts, [:variables | path], value)
  end

  defp add_upload_to_context(opts, name, upload) do
    Keyword.update(
      opts,
      :context,
      %{__absinthe_plug__: %{uploads: %{name => upload}}},
      fn context ->
        Map.update(context, :__absinthe_plug__, %{uploads: %{name => upload}}, fn plug ->
          Map.update(
            plug,
            :uploads,
            %{name => upload},
            &Map.put(&1, name, upload)
          )
        end)
      end
    )
  end
end
