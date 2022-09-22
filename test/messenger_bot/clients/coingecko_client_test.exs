defmodule MessengerBot.Clients.CoingeckoClientTest do
  @moduledoc false
  use ExUnit.Case

  alias MessengerBot.Clients.CoingeckoClient
  alias MessengerBot.Structs.CoinStruct

  import Mox

  setup :verify_on_exit!

  describe "CoingeckoClient.search/1" do
    test "get matching coins list from CoinGecko" do
      query = "usd"

      body = %{
        "coins" => [
          %{"id" => "tether", "name" => "Tether", "symbol" => "USDT"},
          %{"id" => "usd-coin", "name" => "USD Coin", "symbol" => "USDC"},
          %{"id" => "binance-usd", "name" => "Binance USD", "symbol" => "BUSD"},
          %{"id" => "true-usd", "name" => "TrueUSD", "symbol" => "TUSD"},
          %{"id" => "compound-usd-coin", "name" => "cUSDC", "symbol" => "CUSDC"}
        ]
      }

      expect(HttpMock, :get, fn endpoint ->
        assert endpoint =~ query

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!(body)
         }}
      end)

      assert {:ok,
              %{
                coins: [
                  %CoinStruct{id: "tether", name: "Tether", symbol: "USDT"},
                  %CoinStruct{id: "usd-coin", name: "USD Coin", symbol: "USDC"},
                  %CoinStruct{id: "binance-usd", name: "Binance USD", symbol: "BUSD"},
                  %CoinStruct{id: "true-usd", name: "TrueUSD", symbol: "TUSD"},
                  %CoinStruct{id: "compound-usd-coin", name: "cUSDC", symbol: "CUSDC"}
                ]
              }} = CoingeckoClient.search(query)
    end

    test "When on error from CoinGecko search coin shouldn't break" do
      expect(HttpMock, :get, fn _endpoint ->
        {:error, :timeout}
      end)

      assert {:error, :timeout} = CoingeckoClient.search("usd")
    end
  end

  describe "CoingeckoClient.prices/2" do
    test "get price chart for given date" do
      coin_id = "tether"
      date = "25-07-2022"
      price = 1.001980812638723

      body = %{
        "id" => coin_id,
        "market_data" => %{"current_price" => %{"usd" => price}}
      }

      expect(HttpMock, :get, fn endpoint ->
        assert endpoint =~ coin_id
        assert endpoint =~ date

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!(body)
         }}
      end)

      assert {:ok, %{id: ^coin_id, price: ^price}} = CoingeckoClient.prices(coin_id, date)
    end

    test "fails to get price" do
      coin_id = "tether"
      date = "25-07-2022"

      body = %{
        "id" => coin_id
      }

      expect(HttpMock, :get, fn endpoint ->
        assert endpoint =~ coin_id
        assert endpoint =~ date

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!(body)
         }}
      end)

      assert {:ok, %{id: ^coin_id, price: nil}} = CoingeckoClient.prices(coin_id, date)
    end
  end
end
