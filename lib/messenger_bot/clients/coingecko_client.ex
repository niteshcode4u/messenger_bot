defmodule MessengerBot.Clients.CoingeckoClient do
  @moduledoc """
  CoinGecko API implimentation
  """

  require Logger

  alias MessengerBot.Behaviours.Http, as: HTTPAdapter
  alias MessengerBot.Structs.CoinStruct

  @behaviour MessengerBot.Behaviours.Coingecko
  @max_coins 5

  def search(query) do
    get_coingecko_env()
    |> get_search_endpoint(query)
    |> call_get()
  end

  def prices(id, date) do
    get_coingecko_env()
    |> history_endpoint(id, date)
    |> call_get()
  end

  ################################ Private Functions ################################

  defp get_coingecko_env do
    %{
      base_url: base_url,
      version: version,
      search_api: search_api
    } = Application.get_env(:messenger_bot, :coingecko)

    {base_url, version, search_api}
  end

  defp get_search_endpoint({base_url, version, search_api}, query) do
    Path.join([base_url, version, search_api, "?query=#{query}"])
  end

  defp history_endpoint({base_url, version, _search_api}, id, date) do
    Path.join([base_url, version, "coins/#{id}/history", "?date=#{date}"])
  end

  defp call_get(endpoint) do
    case HTTPAdapter.get(endpoint) do
      {:ok, response} ->
        {:ok, response.body |> Jason.decode!() |> parse_response()}

      {:error, error} ->
        Logger.error("Error fetching data, #{inspect(error)}")
        {:error, error}
    end
  end

  defp parse_response(%{"coins" => coins}) do
    coins = coins |> Enum.take(@max_coins) |> Enum.map(&CoinStruct.parse_coin/1)

    %{coins: coins}
  end

  defp parse_response(%{"id" => id, "market_data" => %{"current_price" => %{"usd" => usd_price}}}) do
    %{id: id, price: usd_price}
  end

  defp parse_response(%{"id" => id}) do
    %{id: id, price: nil}
  end
end
