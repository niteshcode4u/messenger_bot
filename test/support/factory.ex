defmodule MessengerBot.Support.Factory do
  @moduledoc false
  use ExMachina

  alias MessengerBot.Message

  def message_factory(attrs) do
    message = %Message{
      id: "99999999999",
      mid: "n_fdasfln_JIUOKLBafadfas",
      text: "Hello Veere",
      recipient_id: "8888888888",
      sender_id: "2131243545233",
      timestamp: 1_658_456_237_532
    }

    merge_attributes(message, attrs)
  end
end
