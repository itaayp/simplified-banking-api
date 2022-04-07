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

      assert 0 == account.balance
    end

    test "deposit an amount into the account balance", ctx do
      account_id = insert(:account, balance: 100).id

      params = %{
        type: "deposit",
        destination: account_id,
        amount: 1
      }

      assert %{"destination" => %{"balance" => 101, "id" => account_id}} =
               ctx.conn
               |> post("/event", params)
               |> json_response(201)

      account = Repo.one(Account, id: account_id)

      assert 101 == account.balance
    end
  end

  describe "POST /event {type: 'withdraw'}" do
    test "withdraw the amount from an account", ctx do
      account_id = insert(:account, balance: 100).id

      params = %{
        type: "withdraw",
        origin: account_id,
        amount: 60
      }

      assert %{"destination" => %{"balance" => 40, "id" => account_id}} =
               ctx.conn
               |> post("/event", params)
               |> json_response(201)

      account = Repo.one(Account, id: account_id)

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

  describe "POST /event {type: 'transfer'}" do
    test "transfer the amount from the origin account to the destination account", ctx do
      origin = insert(:account)
      destination = insert(:account)

      params = %{
        type: "transfer",
        origin: origin.id,
        amount: 60,
        destination: destination.id
      }

      assert %{"origin" => %{"balance" => 40, "id" => origin_id}, "destination" => %{"balance" => 160, "id" => destination_id}} =
               ctx.conn
               |> post("/event", params)
               |> json_response(201)

      assert origin_id == origin.id
      assert destination_id == destination.id
    end

    test "fails if the origin account doesn't exist'", ctx do
      destination_id = insert(:account).id

      params = %{
        type: "transfer",
        origin: 123,
        amount: 60,
        destination: destination_id
      }

      assert ctx.conn
             |> post("/event", params)
             |> response(404)
    end

    test "fails if the destination account doesn't exist'", ctx do
      origin_id = insert(:account).id

      params = %{
        type: "transfer",
        origin: origin_id,
        amount: 60,
        destination: 123
      }

      assert ctx.conn
             |> post("/event", params)
             |> response(404)
    end
  end
end
