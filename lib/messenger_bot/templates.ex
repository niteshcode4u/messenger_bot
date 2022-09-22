defmodule MessengerBot.Templates do
  @moduledoc """
  Response templates
  """

  @chunk_size 3

  def greet do
    """
    Hello <%= name %>, Welcome!

    You can search coins by name or Coin ID -

    For Examples -
      1. list usd
      2. list bitcoin
      3. list usd coin
    """
  end

  def help do
    """
    Start by saying Hello/ Hi/ Hey.

    You can search coins by name or Coin ID -

    For Examples -
      1. list usd
      2. list bitcoin
      3. list usd coin
    --
    Select any of shown coins to get prices for the last 14 days.
    """
  end

  def unknown_cmd do
    """
    Oops, I don't know this command. Can't help.

    Please try by saying help.
    """
  end

  def invalid_inputs do
    """
    Seems invalid input for coins.

    Please try by saying help.
    """
  end

  def list_prices([%{id: id} | _] = prices) do
    (["Last #{length(prices)} days prices for '#{id}'", "---"] ++
       Enum.map(prices, fn %{date: dt, price: p} ->
         """
         #{dt} => #{p} USD
         """
       end))
    |> Enum.join("\n")
  end

  def list_prices(_), do: invalid_inputs()

  def text_response(sender_id, response) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{
        "id" => sender_id
      },
      "message" => %{"text" => response}
    }
  end

  def generic_template_response(sender_id, options \\ []) do
    %{
      # https://developers.facebook.com/docs/messenger-platform/send-messages/#messaging_types
      "messaging_type" => "RESPONSE",
      "recipient" => %{
        "id" => sender_id
      },
      "message" => %{
        "attachment" => %{
          "type" => "template",
          "payload" => %{
            "template_type" => "generic",
            "elements" => button_elements(options)
          }
        }
      }
    }
  end

  ## Private FNs

  defp button_elements(buttons) do
    buttons
    |> Enum.chunk_every(@chunk_size)
    |> Enum.with_index(fn elem_buttons, chunk_index ->
      %{
        "title" =>
          "Top #{@chunk_size * chunk_index + 1}-#{@chunk_size * chunk_index + @chunk_size} search",
        "subtitle" => "Click to get prices",
        "buttons" => buttons_payload(elem_buttons)
      }
    end)
  end

  defp buttons_payload(buttons) do
    Enum.map(buttons, fn %{title: title, payload: payload} ->
      %{
        "type" => "postback",
        "title" => title,
        "payload" => payload
      }
    end)
  end
end
