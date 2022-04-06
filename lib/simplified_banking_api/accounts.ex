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
  If the account doesn't exists, it creates the account, and then deposit the amount.

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
    %{id: account_id, balance: balance}
    |> Account.changeset()
    |> Repo.insert()
    |> case do
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

  @doc """
  Gets the account balance.
  If the account doesn't exists, the function return is `{:error, :not_found}`.

  ## Examples
      # when the account exists
      iex (1)> Accounts.get_balance(1234)
      {:ok, 100}

      # when the account doesn't exists
      iex (1)> Accounts.get_balance(9999)
      {:error, :not_found}
  """
  @spec get_balance(account_id :: integer()) :: {:ok, integer()} | {:error, :not_found}
  def get_balance(account_id) do
    Repo.transaction(fn ->
      case Repo.one(Account, id: account_id) do
        %Account{balance: balance} ->
          Logger.info("#{__MODULE__}: Fetched balance account balance")

          balance

        nil ->
          Logger.error("Account not found")

          Repo.rollback(:not_found)
      end
    end)
  end

  @doc """
  Erases all the existing entries in `accounts` table.
  """
  @spec reset_accounts_table :: {:ok, :success} | {:error, :failed_to_reset}
  def reset_accounts_table do
    Repo.transaction(fn ->
      case Repo.delete_all(Account) do
        {rows, nil} when is_integer(rows) ->
          Logger.info("#{__MODULE__}: All the entries in accounts table were deleted")
          :success

        error ->
          Logger.error("Failed to reset the API. Error: #{inspect(error)}")

          Repo.rollback(:failed_to_reset)
      end
    end)
  end
end
