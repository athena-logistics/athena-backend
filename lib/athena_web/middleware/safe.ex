defmodule AthenaWeb.Middleware.Safe do
  @moduledoc false

  alias AthenaWeb.Endpoint

  require Logger

  @spec add_error_handling(spec :: Absinthe.Middleware.spec()) :: Absinthe.Middleware.spec()
  def add_error_handling(spec), do: &(spec |> to_fun(&1, &2) |> exec_safely(&1))

  # Absinthe Node Error
  defp to_fun(
         {{Absinthe.Relay.Node, :global_id_resolver}, nil},
         %{state: :resolved} = resolution,
         _config
       ) do
    fn -> resolution end
  end

  defp to_fun({{module, function}, config}, resolution, _config) do
    fn -> apply(module, function, [resolution, config]) end
  end

  defp to_fun({module, config}, resolution, _config) do
    fn -> module.call(resolution, config) end
  end

  defp to_fun(module, resolution, config) when is_atom(module) do
    fn -> module.call(resolution, config) end
  end

  defp to_fun(function, resolution, config) when is_function(function, 2) do
    fn -> function.(resolution, config) end
  end

  defp exec_safely(function, resolution) when is_function(function, 0) do
    function.()
  catch
    kind, reason ->
      full_exception = Exception.format(kind, reason, __STACKTRACE__)
      result = AthenaWeb.Exception.result(reason)

      result =
        case {result, Endpoint.config(:debug_errors, false)} do
          {{:ok, _} = result, _} ->
            result

          {{:error, error}, true} ->
            {:error,
             """
             #{inspect(error, pretty: true)}

             DEBUG:
             #{full_exception}
             """}

          {{:error, error}, false} ->
            {:error, error}

          {:unknown, true} ->
            Logger.error("""
            Unknown exception catched:
            #{full_exception}
            """)

            {:error,
             """
             unkown error

             DEBUG:
              #{full_exception}
             """}

          {:unknown, false} ->
            Logger.error("""
            Unknown exception catched:
            #{full_exception}
            """)

            {:error, "unkown error"}
        end

      Absinthe.Resolution.put_result(resolution, result)
  end
end
