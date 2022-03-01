defprotocol AthenaWeb.Exception do
  @fallback_to_any true

  @spec result(exception :: Exception.t()) :: {:ok, term} | {:error, String.t()} | :unknown
  def result(exception)
end

defimpl AthenaWeb.Exception, for: Any do
  @spec result(exception :: Exception.t()) :: {:ok, term} | {:error, String.t()} | :unknown
  def result(%{result: result} = _exception), do: result
  def result(_exception), do: :unknown
end

defimpl AthenaWeb.Exception, for: Ecto.NoResultsError do
  @spec result(exception :: Exception.t()) :: {:ok, term} | {:error, String.t()} | :unknown
  def result(_exception), do: {:ok, nil}
end

defimpl AthenaWeb.Exception, for: Ecto.Query.CastError do
  @spec result(exception :: Exception.t()) :: {:ok, term} | {:error, String.t()} | :unknown
  def result(_exception), do: {:ok, nil}
end
