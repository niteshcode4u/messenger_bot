defmodule MessengerBot do
  @moduledoc """
  MessengerBot keeps the contexts that define your domain
  and business logic. Also, it is used to process Event

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger

  alias MessengerBot.Behaviours.Facebook
  alias MessengerBot.Commands
  alias MessengerBot.Message

  ## https://developers.facebook.com/docs/messenger-platform/getting-started/quick-start
  def handle_event(event) do
    event
    |> Message.parse()
    |> process_event()
  end

  ################################ Private Function ################################
  defp process_event(%Message{sender_id: sender_id, text: text} = message)
       when not is_nil(sender_id) and not is_nil(text) do
    [cmd | params] = String.split(message.text)

    message
    |> Commands.execute(cmd, params)
    |> Facebook.post_message()
  end

  defp process_event({:error, reason}) do
    Logger.error("error processing event - #{inspect(reason)}")
    {:error, reason}
  end
end
