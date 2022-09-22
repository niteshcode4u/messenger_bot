defmodule MessengerBot.Behaviours.Coingecko do
  @moduledoc """
  CoinGecko API behaviour
  """

  ## Doc - https://www.coingecko.com/en/api/documentation

  @cg_client Application.compile_env!(:messenger_bot, :coingecko_client)

  @callback search(query :: String.t()) :: {:ok, any()} | {:error, any()}
  @callback prices(id :: String.t(), date :: String.t()) :: {:ok, any()} | {:error, any()}

  ## Proxies
  def search(query), do: @cg_client.search(query)
  def prices(id, date), do: @cg_client.prices(id, date)
end
