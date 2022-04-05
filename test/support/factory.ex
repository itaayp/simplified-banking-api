defmodule SimplifiedBankingApi.Factory do
  @moduledoc """
  Test factory to insert values in the database.
  """
  use ExMachina.Ecto, repo: SimplifiedBankingApi.Repo

  alias SimplifiedBankingApi.Accounts.Schemas.Account

  # Factories
  def account_factory do
    %Account{
      balance: 100,
      id: 1234,
      inserted_at: ~N[2022-04-05 01:40:11],
      updated_at: ~N[2022-04-05 01:40:11]
    }
  end
end
