defmodule MessengerBot.Structs.CoinStructTest do
  @moduledoc false
  use ExUnit.Case

  alias MessengerBot.Structs.CoinStruct

  describe "CoinStruct.parse/1" do
    test "build struct" do
      id = "tether"
      name = "Tether Coin"
      symbol = "TETH"

      assert %CoinStruct{id: ^id, name: ^name, symbol: ^symbol} =
               CoinStruct.parse_coin(%{"id" => id, "name" => name, "symbol" => symbol})
    end
  end
end
