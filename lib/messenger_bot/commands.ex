defmodule MessengerBot.Commands do
  @moduledoc """
  Handle Message commands and return responses to revert
  """

  @greet ~w(hi Hi hello Hello hey Hey)
  @days_limit 14

  alias MessengerBot.Behaviours.Coingecko
  alias MessengerBot.Behaviours.Facebook
  alias MessengerBot.Message
  alias MessengerBot.Templates

  @spec execute(atom | %{:sender_id => any, optional(any) => any}, any, any) :: %{
          optional(<<_::56, _::_*8>>) => <<_::64>> | %{optional(<<_::16, _::_*16>>) => any}
        }
  def execute(%Message{sender_id: sender_id} = _message, greet, _params) when greet in @greet do
    {:ok, %{"first_name" => first_name}} = Facebook.fetch_profile(sender_id)
    text = EEx.eval_string(Templates.greet(), name: first_name)

    Templates.text_response(sender_id, text)
  end

  def execute(%Message{sender_id: sender_id} = _message, "help", _params) do
    Templates.text_response(sender_id, Templates.help())
  end

  def execute(%Message{} = message, "list", params) do
    params
    |> Enum.join(" ")
    |> Coingecko.search()
    |> parse_coin_list()
    |> case do
      {:ok, coins} when coins != [] ->
        Templates.generic_template_response(message.sender_id, coins)

      _ ->
        Templates.text_response(message.sender_id, Templates.invalid_inputs())
    end
  end

  def execute(%Message{} = message, "prices", params) do
    [currency | _] = params

    prices =
      1..@days_limit
      |> Task.async_stream(
        fn day ->
          date = Date.add(Date.utc_today(), -day)

          get_price_async(currency, "#{date.day}-#{date.month}-#{date.year}")
        end,
        timeout: 10_000,
        max_concurrency: 2,
        on_timeout: :exit
      )
      |> Enum.map(fn {_k, v} -> v end)

    Templates.text_response(message.sender_id, Templates.list_prices(prices))
  end

  def execute(message, _, _) do
    Templates.text_response(message.sender_id, Templates.unknown_cmd())
  end

  ################################ Private Functions ################################
  defp parse_coin_list({:ok, %{coins: coins}}) do
    result =
      Enum.map(coins, fn %{name: name, id: id} ->
        %{title: name, payload: "prices #{id}"}
      end)

    {:ok, result}
  end

  defp parse_coin_list(error), do: error

  defp get_price_async(currency, dt) do
    case Coingecko.prices(currency, dt) do
      {:ok, price} -> Map.put(price, :date, dt)
      _ -> %{price: nil, date: dt}
    end
  end
end
