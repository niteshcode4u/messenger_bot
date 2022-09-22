defmodule MessengerBot.CommandsTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias MessengerBot.Commands
  alias MessengerBot.Structs.CoinStruct

  import Mox
  import MessengerBot.Support.Factory

  setup :verify_on_exit!

  describe "Commands.execute/3" do
    test "command - hello" do
      sender_id = "5304724019611519"

      message = build(:message, sender_id: sender_id)

      expect(FacebookMock, :fetch_profile, fn _ ->
        {:ok,
         %{
           "first_name" => "Nitesh",
           "id" => sender_id,
           "last_name" => "Mishra"
         }}
      end)

      assert %{
               "message" => %{"text" => text},
               "messaging_type" => "RESPONSE",
               "recipient" => %{"id" => ^sender_id}
             } = Commands.execute(message, "hello", ["any", "other", "data"])

      assert text =~
               "Hello Nitesh, Welcome!\n\nYou can search coins by name or Coin ID -\n\nFor Examples -\n  1. list usd\n  2. list bitcoin\n  3. list usd coin\n"
    end

    test "command - help" do
      sender_id = "5304724019611519"

      message = build(:message, sender_id: sender_id)

      assert %{
               "message" => %{
                 "text" =>
                   "Start by saying Hello/ Hi/ Hey.\n\nYou can search coins by name or Coin ID -\n\nFor Examples -\n  1. list usd\n  2. list bitcoin\n  3. list usd coin\n--\nSelect any of shown coins to get prices for the last 14 days.\n"
               },
               "messaging_type" => "RESPONSE",
               "recipient" => %{"id" => ^sender_id}
             } = Commands.execute(message, "help", ["any", "other", "data"])
    end

    test "unsupported command" do
      sender_id = "5304724019611519"
      message = build(:message, sender_id: sender_id)

      assert %{
               "message" => %{
                 "text" =>
                   "Oops, I don't know this command. Can't help.\n\nPlease try by saying help.\n"
               },
               "messaging_type" => "RESPONSE",
               "recipient" => %{"id" => ^sender_id}
             } = Commands.execute(message, "xyz", ["any", "other", "data"])
    end

    test "command - list <query>" do
      sender_id = "5304724019611519"
      message = build(:message, sender_id: sender_id)

      expect(CoingeckoMock, :search, fn "usd" ->
        {:ok,
         %{
           coins: [
             %CoinStruct{id: "tether", name: "Tether", symbol: "USDT"},
             %CoinStruct{id: "usd-coin", name: "USD Coin", symbol: "USDC"},
             %CoinStruct{id: "binance-usd", name: "Binance USD", symbol: "BUSD"},
             %CoinStruct{id: "true-usd", name: "TrueUSD", symbol: "TUSD"},
             %CoinStruct{id: "compound-usd-coin", name: "cUSDC", symbol: "CUSDC"}
           ]
         }}
      end)

      assert %{
               "message" => %{
                 "attachment" => %{
                   "payload" => %{
                     "elements" => [
                       %{
                         "buttons" => [
                           %{
                             "payload" => "prices tether",
                             "title" => "Tether",
                             "type" => "postback"
                           },
                           %{
                             "payload" => "prices usd-coin",
                             "title" => "USD Coin",
                             "type" => "postback"
                           },
                           %{
                             "payload" => "prices binance-usd",
                             "title" => "Binance USD",
                             "type" => "postback"
                           }
                         ],
                         "subtitle" => "Click to get prices",
                         "title" => "Top 1-3 search"
                       },
                       %{
                         "buttons" => [
                           %{
                             "payload" => "prices true-usd",
                             "title" => "TrueUSD",
                             "type" => "postback"
                           },
                           %{
                             "payload" => "prices compound-usd-coin",
                             "title" => "cUSDC",
                             "type" => "postback"
                           }
                         ],
                         "subtitle" => "Click to get prices",
                         "title" => "Top 4-6 search"
                       }
                     ],
                     "template_type" => "generic"
                   },
                   "type" => "template"
                 }
               },
               "messaging_type" => "RESPONSE",
               "recipient" => %{"id" => ^sender_id}
             } = Commands.execute(message, "list", ["usd"])
    end

    test "command - list - when error from CoinGecko" do
      message = build(:message, sender_id: "5304724019611519")

      expect(CoingeckoMock, :search, fn _ ->
        {:error, :timeout}
      end)

      assert %{
               "message" => %{
                 "text" => "Seems invalid input for coins.\n\nPlease try by saying help.\n"
               },
               "messaging_type" => "RESPONSE",
               "recipient" => %{"id" => "5304724019611519"}
             } == Commands.execute(message, "list", ["usd"])
    end

    test "command - prices <coin-id>" do
      sender_id = "5304724019611519"
      message = build(:message, sender_id: sender_id)
      price = 1.001980812638723

      expect(CoingeckoMock, :prices, 14, fn "tether", _date ->
        {:ok,
         %{
           id: "tether",
           price: price
         }}
      end)

      assert %{
               "message" => %{
                 "text" => text
               },
               "messaging_type" => "RESPONSE",
               "recipient" => %{"id" => ^sender_id}
             } = Commands.execute(message, "prices", ["tether"])

      assert text =~ "Last 14 days prices for 'tether'"
      assert text =~ "=> #{price} USD"
    end

    test "command - prices - when error from CoinGecko" do
      message = build(:message, sender_id: "5304724019611519")

      expect(CoingeckoMock, :prices, 14, fn _curr, _date ->
        {:error, :nil_price}
      end)

      assert %{
               "message" => %{
                 "text" => "Seems invalid input for coins.\n\nPlease try by saying help.\n"
               },
               "messaging_type" => "RESPONSE",
               "recipient" => %{"id" => "5304724019611519"}
             } == Commands.execute(message, "prices", ["tether"])
    end
  end
end
