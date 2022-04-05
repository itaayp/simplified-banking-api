defmodule SimplifiedBankingApi.Accounts do
  @moduledoc """
  Accounts Context.

  This module is responsable to handle all operations related to Accounts
  """
  require Logger

  alias SimplifiedBankingApi.Repo
  alias SimplifiedBankingApi.Accounts.Schemas.Account

  @doc """
  Deposit money into an account.
  If the account doesn't exists, it creates the account, and then deposit the amount

  ## Examples
      iex> Accounts.deposit(1234, 100)
      %{:ok, %SimplifiedBankingApi.Accounts.Schemas.Account{
        __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
        balance: 100,
        id: 1234,
        inserted_at: ~N[2022-04-05 03:26:44],
        updated_at: ~N[2022-04-05 03:26:44]
      }}
  """
  @spec deposit(account_id :: integer(), amount :: integer()) ::
          {:ok, Account.t()} | {:error, atom()}
  def deposit(account_id, amount) do
    Repo.transaction(fn ->
      with %Account{} = account <- Repo.get(Account, account_id),
           changeset <- Account.update_changeset(account, %{balance: account.balance + amount}),
           {:ok, account} <- Repo.update(changeset) do
        account
      else
        nil ->
          create_account(account_id, amount)

        {:error, reason} ->
          Logger.error("""
          Failed to deposit into an account.
          Account id: #{inspect(account_id)}.
          Reason: #{inspect(reason)}.
          """)

          Repo.rollback(reason)
      end
    end)
  end

  defp create_account(account_id, balance) do
    account_changeset = Account.changeset(%{id: account_id, balance: balance})

    case Repo.insert(account_changeset) do
      {:ok, account} ->
        Logger.info("#{__MODULE__}: Account #{account_id} created")
        account

      {:error, reason} ->
        Logger.error("""
        Failed to create account.
        Reason: #{inspect(reason)}.
        """)

        Repo.rollback(reason)
    end
  end

  def reset_data do
    case Repo.delete_all(Account) do
      {rows, nil} when is_integer(rows) -> {:ok, :success}
      error ->
        Logger.error("Failed to reset the API. Error: #{inspect(error)}")

        {:error, :failed_to_reset}
    end
  end
end
