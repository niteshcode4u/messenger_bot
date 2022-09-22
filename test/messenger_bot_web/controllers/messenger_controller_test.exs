defmodule MessengerBotWeb.MessengerControllerTest do
  use MessengerBotWeb.ConnCase, async: true

  import Mox

  setup :verify_on_exit!

  describe "Router - validate_token" do
    test "Successfully validate token", %{conn: conn} do
      params = %{
        "hub.challenge" => "4344534534953",
        "hub.mode" => "subscribe",
        "hub.verify_token" => "Dummy_token_for_fb_page_access"
      }

      resp =
        conn
        |> get("/api/messenger_webhook", params)
        |> json_response(200)

      assert 4_344_534_534_953 == resp
    end

    test "error on invalid challenge", %{conn: conn} do
      params = %{
        "hub.challenge" => "434453swswsw4534953",
        "hub.mode" => "subscribe",
        "hub.verify_token" => "Dummy_token_for_fb_page_access"
      }

      resp =
        conn
        |> get("/api/messenger_webhook", params)
        |> json_response(403)

      assert resp == %{"status" => "error", "message" => "unauthorized"}
    end

    test "error when not found", %{conn: conn} do
      resp =
        conn
        |> get("/api/messenger_webhook", %{})
        |> json_response(404)

      assert resp == %{"status" => "error", "message" => "not_found"}
    end
  end

  describe "Router - handle_message/2" do
    test "successfully process message event", %{conn: conn} do
      sender_id = "423247529748523"

      params = %{
        "entry" => [
          %{
            "id" => "4344534534953",
            "messaging" => [
              %{
                "message" => %{
                  "mid" => "Dummy_token_for_fb_page_access",
                  "text" => "hey"
                },
                "recipient" => %{"id" => "4344534534953"},
                "sender" => %{"id" => sender_id},
                "timestamp" => 1_653_533_237_494
              }
            ]
          }
        ]
      }

      expect(FacebookMock, :fetch_profile, fn _ ->
        {:ok,
         %{
           "first_name" => "Nitesh",
           "id" => "423247529748523",
           "last_name" => "Mishra"
         }}
      end)

      expect(FacebookMock, :post_message, fn _ ->
        {:ok,
         %{
           "message_id" => "Dummy_token_for_fb_page_access",
           "recipient_id" => sender_id
         }}
      end)

      conn = post(conn, "/api/messenger_webhook", params)
      assert %{"status" => "ok", "message" => "received"} = json_response(conn, 200)
    end

    test "Error when malformed request sent", %{conn: conn} do
      conn = post(conn, "/api/messenger_webhook", %{"entry" => [%{}]})
      assert %{"message" => ":invalid_message", "status" => "error"} = json_response(conn, 404)
    end

    test "error when not found", %{conn: conn} do
      resp =
        conn
        |> post("/api/messenger_webhook", %{})
        |> json_response(404)

      assert resp == %{"status" => "error", "message" => "not_found"}
    end
  end
end
