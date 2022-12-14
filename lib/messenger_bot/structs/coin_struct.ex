defmodule MessengerBot.Structs.CoinStruct do
  @moduledoc false

  @enforce_keys [:id, :name, :symbol]
  defstruct [:id, :name, :symbol]

  def parse_coin(%{"id" => id, "name" => name, "symbol" => symbol}) do
    %__MODULE__{id: id, name: name, symbol: symbol}
  end
end
