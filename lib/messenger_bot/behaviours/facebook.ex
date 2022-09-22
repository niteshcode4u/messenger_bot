defmodule MessengerBot.Behaviours.Facebook do
  @moduledoc """
  Facebook API behaviour
  """

  @fb_client Application.compile_env!(:messenger_bot, :facebook_client)

  @callback post_message(message :: map()) :: {:ok, any()} | {:error, any()}
  @callback fetch_profile(customer_id :: String.t()) :: {:ok, any()} | {:error, any()}

  ## Proxies
  def post_message(message), do: @fb_client.post_message(message)
  def fetch_profile(customer_id), do: @fb_client.fetch_profile(customer_id)
end
