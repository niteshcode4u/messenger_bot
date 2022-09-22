defmodule MessengerBotTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias MessengerBot.Structs.CoinStruct

  import Mox

  setup :verify_on_exit!

  describe "MessengerBot.handle_event/1" do
    test "successfully process a message event" do
      sender_id = "491834609178440569"

      event = %{
        "id" => "108056681991744",
        "messaging" => [
          %{
            "message" => %{
              "mid" => "nit_nckldjbnfIKBJLKKkmfclanbfad",
              "text" => "hi"
            },
            "recipient" => %{"id" => "108056681991744"},
            "sender" => %{"id" => sender_id},
            "timestamp" => 1_658_851_237_494
          }
        ]
      }

      expect(FacebookMock, :fetch_profile, fn _ ->
        {:ok,
         %{
           "first_name" => "Nitesh",
           "id" => "491834609178440569",
           "last_name" => "Mishra"
         }}
      end)

      expect(FacebookMock, :post_message, fn _ ->
        {:ok,
         %{
           "message_id" => "nit_nckldjbnfIKBJLKKkmfclanbfad",
           "recipient_id" => sender_id
         }}
      end)

      assert {:ok,
              %{
                "message_id" => "nit_nckldjbnfIKBJLKKkmfclanbfad",
                "recipient_id" => "491834609178440569"
              }} == MessengerBot.handle_event(event)
    end

    test "successfully process a message event - list" do
      sender_id = "491834609178440569"

      event = %{
        "id" => "108056681991744",
        "messaging" => [
          %{
            "message" => %{
              "mid" => "nit_nckldjbnfIKBJLKKkmfclanbfad",
              "text" => "list usd"
            },
            "recipient" => %{"id" => "108056681991744"},
            "sender" => %{"id" => sender_id},
            "timestamp" => 1_658_919_250_339
          }
        ]
      }

      expect(FacebookMock, :fetch_profile, 0, fn ^sender_id ->
        {:ok, %{}}
      end)

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

      expect(FacebookMock, :post_message, fn %{
                                               "messaging_type" => "RESPONSE",
                                               "recipient" => %{"id" => _},
                                               "message" => %{
                                                 "attachment" => %{
                                                   "type" => "template",
                                                   "payload" => %{
                                                     "template_type" => "generic",
                                                     "elements" => [
                                                       %{
                                                         "subtitle" => _,
                                                         "title" => _,
                                                         "buttons" => [
                                                           %{
                                                             "payload" => _,
                                                             "title" => _,
                                                             "type" => _
                                                           }
                                                           | _
                                                         ]
                                                       }
                                                       | _
                                                     ]
                                                   }
                                                 }
                                               }
                                             } ->
        {:ok,
         %{
           "message_id" => "nit_nckldjbnfIKBJLKKkmfclanbfad",
           "recipient_id" => sender_id
         }}
      end)

      assert {:ok,
              %{
                "message_id" => "nit_nckldjbnfIKBJLKKkmfclanbfad",
                "recipient_id" => "491834609178440569"
              }} == MessengerBot.handle_event(event)
    end

    test "successfully process a postback event - prices" do
      sender_id = "491834609178440569"

      event = %{
        "id" => "108056681991744",
        "messaging" => [
          %{
            "postback" => %{
              "mid" => "m_hZDuN0CzOT2rY0dDDQuLFa2CKPrxrW0J9N_b8Q",
              "payload" => "prices tether",
              "title" => "Tether"
            },
            "recipient" => %{"id" => "108056681991744"},
            "sender" => %{"id" => sender_id},
            "timestamp" => 1_658_919_250_339
          }
        ]
      }

      expect(FacebookMock, :fetch_profile, 0, fn _ ->
        {:ok, %{}}
      end)

      expect(CoingeckoMock, :prices, 14, fn coin_id, _date ->
        {:ok,
         %{
           id: coin_id,
           price: 1.001980812638723
         }}
      end)

      expect(FacebookMock, :post_message, fn %{
                                               "messaging_type" => "RESPONSE",
                                               "recipient" => %{"id" => ^sender_id},
                                               "message" => %{
                                                 "text" => _
                                               }
                                             } ->
        {:ok,
         %{
           "message_id" => "nit_nckldjbnfIKBJLKKkmfclanbfad",
           "recipient_id" => sender_id
         }}
      end)

      assert {:ok,
              %{
                "message_id" => "nit_nckldjbnfIKBJLKKkmfclanbfad",
                "recipient_id" => "491834609178440569"
              }} == MessengerBot.handle_event(event)
    end
  end
end
