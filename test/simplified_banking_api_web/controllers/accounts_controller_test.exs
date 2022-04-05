defmodule SimplifiedBankingApiWeb.AccountsControllerTest do
  use SimplifiedBankingApiWeb.ConnCase, async: false

  import SimplifiedBankingApi.Factory

  alias SimplifiedBankingApi.Repo
  alias SimplifiedBankingApi.Accounts.Schemas.Account

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST /event {type: 'deposit'}" do
    test "succeds creating an account with balance", ctx do
      params = %{
        type: "deposit",
        destination: "1234",
        amount: 10
      }

      assert [] == Repo.all(Account, [])

      assert %{"destination" => %{"balance" => 10, "id" => 1234}} =
               ctx.conn
               |> post("/event", params)
               |> json_response(201)

      [account] = Repo.all(Account, [])

      assert 1234 == account.id
      assert 10 == account.balance
    end

    test "succeds creating an account without specifing the balance", ctx do
      params = %{
        type: "deposit",
        destination: "1234"
      }

      assert [] == Repo.all(Account, [])

      assert %{"destination" => %{"balance" => 0, "id" => 1234}} =
               ctx.conn
               |> post("/event", params)
               |> json_response(201)

      [account] = Repo.all(Account, [])

      assert 1234 == account.id
      assert 0 == account.balance
    end

    test "deposit an amount into the account balance", ctx do
      account_id = 123

      insert(:account, id: account_id, balance: 100)

      params = %{
        type: "deposit",
        destination: account_id,
        amount: 1
      }

      assert %{"destination" => %{"balance" => 101, "id" => account_id}} =
               ctx.conn
               |> post("/event", params)
               |> json_response(201)

      [account] = Repo.all(Account, [])

      assert account_id == account.id
      assert 101 == account.balance
    end
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
