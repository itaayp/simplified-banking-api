defmodule SimplifiedBankingApiWeb.EventsControllerTest do
  use SimplifiedBankingApiWeb.ConnCase, async: false

  import SimplifiedBankingApi.Factory

  alias SimplifiedBankingApi.Accounts.Schemas.Account
  alias SimplifiedBankingApi.Repo

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

      assert %{"origin" => %{"balance" => 40, "id" => account_id}} =
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
    setup do
      origin_account_id = insert(:account, balance: 100).id
      destination_account_id = insert(:account, balance: 100).id

      {:ok, origin: origin_account_id, destination: destination_account_id}
    end

    test "transfer the amount from the origin account to the destination account", ctx do
      params = %{
        type: "transfer",
        origin: ctx.origin,
        amount: 60,
        destination: ctx.destination
      }

      assert %{
               "origin" => %{"balance" => 40, "id" => origin_id},
               "destination" => %{"balance" => 160, "id" => destination_id}
             } =
               ctx.conn
               |> post("/event", params)
               |> json_response(201)

      assert origin_id == ctx.origin
      assert destination_id == ctx.destination
    end

    test "fails if the origin account doesn't exist'", ctx do
      params = %{
        type: "transfer",
        origin: 123,
        amount: 60,
        destination: ctx.destination
      }

      assert ctx.conn
             |> post("/event", params)
             |> response(404)
    end

    test "create a new account if the destination doesn't exist", %{origin: origin_id} = ctx do
      destination_id = "123"

      params = %{
        type: "transfer",
        origin: origin_id,
        amount: 60,
        destination: destination_id
      }

      assert %{
               "origin" => %{"balance" => 40, "id" => origin_id},
               "destination" => %{"balance" => 60, "id" => destination_id}
             } ==
               ctx.conn
               |> post("/event", params)
               |> json_response(201)
    end
  end
end
