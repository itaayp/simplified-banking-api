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
      account_id = 123

      insert(:account, id: account_id, balance: 100)

      assert {:ok, account} = Accounts.deposit(account_id, 1)

      assert 101 == account.balance
    end
  end
end
