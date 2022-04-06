defmodule SimplifiedBankingApiWeb.BalanceControllerTest do
  use SimplifiedBankingApiWeb.ConnCase, async: true

  import SimplifiedBankingApi.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET /balance" do
    test "succeds getting account balance", ctx do
      insert(:account, id: 1, balance: 1000)

      assert "1000" ==
               ctx.conn
               |> get("/balance", %{account_id: 1})
               |> response(200)
    end

    test "fails to get the balance if the account doesn't exist'", ctx do
      assert ctx.conn
             |> get("/balance", %{account_id: 1})
             |> response(404)
    end
  end
end
