defmodule MessengerBot.TemplatesTest do
  @moduledoc false
  use ExUnit.Case, async: false

  alias MessengerBot.Templates

  describe "Templates.render template" do
    test "greet" do
      name = "Nitesh"

      greeting = """
      Hello #{name}, Welcome!

      You can search coins by name or Coin ID -

      For Examples -
        1. list usd
        2. list bitcoin
        3. list usd coin
      """

      assert greeting == EEx.eval_string(Templates.greet(), name: name)
    end

    test "help" do
      msg = """
      Start by saying Hello/ Hi/ Hey.

      You can search coins by name or Coin ID -

      For Examples -
        1. list usd
        2. list bitcoin
        3. list usd coin
      --
      Select any of shown coins to get prices for the last 14 days.
      """

      assert msg == Templates.help()
    end

    test "unknown_cmd" do
      msg = """
      Oops, I don't know this command. Can't help.

      Please try by saying help.
      """

      assert msg == Templates.unknown_cmd()
    end

    test "invalid_inputs" do
      msg = """
      Seems invalid input for coins.

      Please try by saying help.
      """

      assert msg == Templates.invalid_inputs()
    end
  end

  describe "Templates.list_prices/1" do
    test "empty list" do
      msg = Templates.invalid_inputs()
      assert msg == Templates.list_prices([])
    end

    test "render list" do
      prices = [
        %{id: "id1", date: "21", price: 10.0},
        %{id: "id2", date: "22", price: 10.1}
      ]

      msg = """
      Last 2 days prices for 'id1'
      ---
      21 => 10.0 USD

      22 => 10.1 USD
      """

      assert msg == Templates.list_prices(prices)
    end
  end

  describe "Templates.text_response/2" do
    test "render text msg" do
      sender = "nitesh-id"
      text = "response text"

      msg = %{
        "messaging_type" => "RESPONSE",
        "recipient" => %{
          "id" => sender
        },
        "message" => %{"text" => text}
      }

      assert ^msg = Templates.text_response(sender, text)
    end
  end

  describe "Templates.generic_template_response/2" do
    test "render without data" do
      sender = "sender-id"

      msg = %{
        "message" => %{
          "attachment" => %{
            "payload" => %{"elements" => [], "template_type" => "generic"},
            "type" => "template"
          }
        },
        "messaging_type" => "RESPONSE",
        "recipient" => %{"id" => sender}
      }

      assert ^msg = Templates.generic_template_response(sender, [])
    end

    test "render data" do
      sender = "nitesh-id"

      buttons = [
        %{title: "tether", payload: "prices tether"},
        %{title: "id1", payload: "payload1"},
        %{title: "id2", payload: "payload2"},
        %{title: "id3", payload: "payload3"}
      ]

      msg = %{
        "message" => %{
          "attachment" => %{
            "payload" => %{
              "elements" => [
                %{
                  "buttons" => [
                    %{"payload" => "prices tether", "title" => "tether", "type" => "postback"},
                    %{"payload" => "payload1", "title" => "id1", "type" => "postback"},
                    %{"payload" => "payload2", "title" => "id2", "type" => "postback"}
                  ],
                  "subtitle" => "Click to get prices",
                  "title" => "Top 1-3 search"
                },
                %{
                  "buttons" => [
                    %{"payload" => "payload3", "title" => "id3", "type" => "postback"}
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
        "recipient" => %{"id" => sender}
      }

      assert ^msg = Templates.generic_template_response(sender, buttons)
    end
  end
end
