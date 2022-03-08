defmodule AthenaWeb.Schema.SubscriptionConfig do
  @moduledoc false

  @spec topics(
          topics :: [String.t() | nil | {String.t(), nil | String.t()}],
          fallback :: [String.t() | nil | {String.t(), nil | String.t()}]
        ) ::
          [{:topic, String.t()}]
  def topics(topics \\ [], fallback \\ []) do
    topics
    |> filter_topics()
    |> case do
      [] -> filter_topics(fallback)
      [_opic | _others] = topics -> topics
    end
  end

  defp filter_topics(topics),
    do:
      topics
      |> Enum.reject(&match?(nil, &1))
      |> Enum.reject(&match?({_sub_resource, nil}, &1))
      |> Enum.map(&to_topic/1)
      |> Enum.map(&{:topic, &1})

  defp to_topic(topic)

  defp to_topic({sub_resource, id}) when is_binary(sub_resource) and is_binary(id),
    do: sub_resource <> ":" <> id

  defp to_topic(topic) when is_binary(topic), do: topic
end
