defmodule SimplifiedBankingApiWeb.EventsControllerTest do
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

      account = Repo.one(Account, id: 1234)

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

      account = Repo.one(Account, id: 1234)

      assert 1234 == account.id
      assert 0 == account.balance
    end

    test "deposit an amount into the account balance", ctx do
      insert(:account, id: 123, balance: 100)

      params = %{
        type: "deposit",
        destination: 123,
        amount: 1
      }

      assert %{"destination" => %{"balance" => 101, "id" => 123}} =
               ctx.conn
               |> post("/event", params)
               |> json_response(201)

      account = Repo.one(Account, id: 123)

      assert 123 == account.id
      assert 101 == account.balance
    end
  end

  describe "POST /event {type: 'withdraw'}" do
    test "withdraw the amount from an account", ctx do
      insert(:account, id: 123, balance: 100)

      params = %{
        type: "withdraw",
        origin: 123,
        amount: 60
      }

      assert %{"destination" => %{"balance" => 40, "id" => account_id}} =
               ctx.conn
               |> post("/event", params)
               |> json_response(201)

      account = Repo.one(Account, id: 123)

      assert account_id == account.id
      assert 40 == account.balance
    end

    test "fails if the account doesn't exist'", ctx do
      params = %{
        type: "withdraw",
        origin: 123,
        amount: 60
      }

      assert ctx.conn
             |> post("/event", params)
             |> response(404)
    end
  end
end
