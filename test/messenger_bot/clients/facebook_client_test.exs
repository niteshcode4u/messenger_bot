defmodule MessengerBot.Clients.FacebookClientTest do
  @moduledoc false
  use ExUnit.Case

  alias MessengerBot.Clients.FacebookClient

  import Mox

  setup :verify_on_exit!

  describe "FacebookClient.post_message/1" do
    test "post message to facebook" do
      sender_id = "14214545432534"

      message = %{
        "message" => %{"text" => "Hi Nitesh, Welcome!\n"},
        "messaging_type" => "RESPONSE",
        "recipient" => %{"id" => sender_id}
      }

      body = %{
        "message_id" => "nit_bnclkasfgvaiksdfgbkdmvlgbkds",
        "recipient_id" => sender_id
      }

      expect(HttpMock, :post, fn _endpoint, _, _opts ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!(body)
         }}
      end)

      assert {:ok, ^body} = FacebookClient.post_message(message)
    end

    test "When on error from facebook post message shouldn't break" do
      sender_id = "14214545432534"

      message = %{
        "message" => %{"text" => "Hi Nitesh, Welcome!\n"},
        "messaging_type" => "RESPONSE",
        "recipient" => %{"id" => sender_id}
      }

      expect(HttpMock, :post, fn _endpoint, _, _opts ->
        {:error, :timeout}
      end)

      assert {:error, :timeout} == FacebookClient.post_message(message)
    end
  end

  describe "FacebookClient.fetch_profile/1" do
    test "fetch profile from facebook" do
      sender_id = "14214545432534"

      body = %{
        "first_name" => "Nitesh",
        "id" => sender_id,
        "last_name" => "Doe"
      }

      expect(HttpMock, :get, fn endpoint ->
        assert endpoint =~ sender_id

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!(body)
         }}
      end)

      assert {:ok, ^body} = FacebookClient.fetch_profile(sender_id)
    end

    test "When on error from facebook fetch profile shouldn't break" do
      sender_id = "14214545432534"

      expect(HttpMock, :get, fn endpoint ->
        {:error, :timeout}
      end)

      assert {:error, :timeout} = FacebookClient.fetch_profile(sender_id)
    end
  end
end
