defmodule SimplifiedBankingApiWeb.BalanceControllerTest do
  use SimplifiedBankingApiWeb.ConnCase, async: true

  import SimplifiedBankingApi.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET /balance" do
    test "succeeds getting account balance", ctx do
      account_id = insert(:account, balance: 1000).id

      assert "1000" ==
               ctx.conn
               |> get("/balance", %{account_id: account_id})
               |> response(200)
    end

    test "fails to get the balance if the account doesn't exist", ctx do
      assert ctx.conn
             |> get("/balance", %{account_id: "1"})
             |> response(404)
    end

    test "fails to get the balance if the account_id isn't specified", ctx do
      assert %{"error" => %{"account_id" => "can't be blank"}} ==
               ctx.conn
               |> get("/balance")
               |> json_response(422)
    end
  end
end
