defmodule MessengerBot.Behaviours.Http do
  @moduledoc """
  HTTP API interface
  """

  @htttp_adapter Application.compile_env!(:messenger_bot, :http_adapter)

  @callback get(api :: String.t()) :: {:ok, any()} | {:error, any()}
  @callback post(api :: String.t(), payload :: any(), options :: any()) ::
              {:ok, any()} | {:error, any()}

  def get(api), do: @htttp_adapter.get(api)
  def post(api, payload, options), do: @htttp_adapter.post(api, payload, options)
end
