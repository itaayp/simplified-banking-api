defmodule SimplifiedBankingApiWeb.ResetControllerTest do
  use SimplifiedBankingApiWeb.ConnCase, async: true

  import SimplifiedBankingApi.Factory

  alias SimplifiedBankingApi.Repo
  alias SimplifiedBankingApi.Accounts.Schemas.Account

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST /reset" do
    test "succeds reseting the API", ctx do
      insert_list(7, :account)

      assert 7 == Repo.aggregate(Account, :count)

      assert ctx.conn
             |> post("/reset", %{})
             |> response(200)

      # the database is empty
      assert [] == Repo.all(Account, [])
    end
  end
end
