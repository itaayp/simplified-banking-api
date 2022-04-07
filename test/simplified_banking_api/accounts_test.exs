defmodule SimplifiedBankingApi.AccountsTest do
  use SimplifiedBankingApi.DataCase

  import SimplifiedBankingApi.Factory

  alias SimplifiedBankingApi.{Accounts, Repo}
  alias SimplifiedBankingApi.Accounts.Schemas.Account

  describe "deposit/2" do
    test "creates an account and deposit the amount when the account doesnt exists" do
      assert [] == Repo.all(Account, [])

      assert {:ok, _account} = Accounts.deposit(1234, 100)

      [account] = Repo.all(Account, [])

      assert 1234 == account.id
      assert 100 == account.balance
    end

    test "deposit an amount into the account balance" do
      account_id = insert(:account, balance: 100).id

      assert {:ok, account} = Accounts.deposit(account_id, 1)

      assert 101 == account.balance
    end
  end

  describe "withdraw/2" do
    test "withdraw the amount from an account" do
      account_id = insert(:account, balance: 100).id

      assert {:ok, account} = Accounts.withdraw(account_id, 30)

      assert 70 == account.balance
    end

    test "fails if the account doesn't exist" do
      assert {:error, :not_found} = Accounts.withdraw(123, 1000)
    end
  end

  describe "transfer/3" do
    setup do
      origin_account_id = insert(:account, balance: 100).id
      destination_account_id = insert(:account, balance: 100).id

      {:ok, origin_account: origin_account_id, destination_account: destination_account_id}
    end

    test "transfer the amount from the origin_account to the destination_account", ctx do
      assert {:ok, origin, destination} =
               Accounts.transfer(ctx.origin_account, 30, ctx.destination_account)

      assert 70 == origin.balance
      assert 130 == destination.balance
    end

    test "fails if the origin account doesn't exist", ctx do
      assert {:error, :not_found} = Accounts.transfer(123, 1000, ctx.destination_account)
    end

    test "fails if the destination account doesn't exist", ctx do
      assert {:error, :not_found} = Accounts.transfer(ctx.origin_account, 1000, 567)
    end
  end

  describe "get_balance/1" do
    test "successfully get the account balance" do
      account_id = insert(:account, balance: 1000).id

      assert {:ok, 1000} == Accounts.get_balance(account_id)
    end

    test "fails if the account doesn't exist" do
      assert {:error, :not_found} == Accounts.get_balance(1)
    end
  end

  describe "reset_accounts_table/0" do
    test "resets all the database data" do
      insert(:account, id: 1)

      insert_list(8, :account)

      assert 9 == Repo.aggregate(Account, :count)

      Accounts.reset_accounts_table()

      # the database is empty
      assert [] == Repo.all(Account, [])

      # can create a new account with the same id that was previously used
      insert(:account, id: 1)
    end
  end
end
