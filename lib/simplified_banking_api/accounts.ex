defmodule SimplifiedBankingApi.Accounts do
  @moduledoc """
  Accounts Context.

  This module is responsable to handle all operations related to Accounts
  """
  require Logger

  alias SimplifiedBankingApi.Accounts.Schemas.Account
  alias SimplifiedBankingApi.Repo

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
      case operate_account(account_id, amount, :sum) do
        {:ok, %Account{} = account} ->
          account

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
  Withdraw money from an account.
  If the `origin` doesn't match with any account_id, the function returns `{:error, :not_found}`.

  ## Examples
      iex> Accounts.withdraw(1234, 10)
      %{:ok, %SimplifiedBankingApi.Accounts.Schemas.Account{
        __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
        balance: 90,
        id: 1234,
        inserted_at: ~N[2022-04-05 03:26:44],
        updated_at: ~N[2022-06-13 12:33:48]
      }}
  """
  @spec withdraw(account_id :: integer(), amount :: integer()) ::
          {:ok, Account.t()} | {:error, atom()}
  def withdraw(account_id, amount) do
    Repo.transaction(fn ->
      case operate_account(account_id, amount, :subtract) do
        {:ok, %Account{} = account} ->
          account

        nil ->
          Logger.error("Account not found")
          Repo.rollback(:not_found)

        {:error, reason} ->
          Logger.error("""
          Failed to withdraw.
          Account id: #{inspect(account_id)}.
          Reason: #{inspect(reason)}.
          """)

          Repo.rollback(reason)
      end
    end)
  end

  @doc """
  Transfers the `amount` from the `origin_account` to the `destination_account`.
  If the `origin_account`, or the `destination_account` don't match with any account_id,
  so the function returns `{:error, :not_found}`.

  ## Examples
      iex> Accounts.transfer(1234, 10, 5678)
      %{
        :ok,
        %SimplifiedBankingApi.Accounts.Schemas.Account{
        __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
        balance: 90,
        id: 1234,
        inserted_at: ~N[2022-04-05 03:26:44],
        updated_at: ~N[2022-06-13 12:33:48]
      },
      %{
        :ok,
        %SimplifiedBankingApi.Accounts.Schemas.Account{
        __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
        balance: 110,
        id: 5678,
        inserted_at: ~N[2022-04-05 03:26:44],
        updated_at: ~N[2022-06-13 12:33:48]
      }
    }
  """
  @spec transfer(
          origin_account :: integer(),
          amount :: integer(),
          destination_account :: integer()
        ) ::
          {:ok, origin :: Account.t(), destination :: Account.t()} | {:error, atom()}
  def transfer(origin_account, amount, destination_account) do
    Repo.transaction(fn ->
      with {:origin, {:ok, %Account{} = origin}} <-
             {:origin, operate_account(origin_account, amount, :subtract)},
           {:destination, {:ok, %Account{} = destination}} <-
             {:destination, operate_account(destination_account, amount, :sum)} do
        {origin, destination}
      else
        {:origin, nil} ->
          Logger.error("Origin account not found")
          Repo.rollback(:not_found)

        {:destination, nil} ->
          Logger.error("Destination account not found")
          Repo.rollback(:not_found)

        {_, {:error, reason}} ->
          Logger.error("""
          Failed to transfer.
          Origin account id: #{inspect(origin_account)}.
          Destination account id: #{inspect(destination_account)}.
          Reason: #{inspect(reason)}.
          """)

          Repo.rollback(reason)
      end
    end)
    |> case do
      {:ok, {origin, destination}} -> {:ok, origin, destination}
      any -> any
    end
  end

  defp operate_account(account_id, amount, operation) when operation in [:sum, :subtract] do
    with %Account{} = account <- Repo.get(Account, account_id),
         changeset <-
           Account.update_changeset(account, update_balance(account.balance, amount, operation)) do
      Repo.update(changeset)
    end
  end

  defp update_balance(balance, amount, operation)
  defp update_balance(balance, amount, :sum), do: %{balance: balance + amount}
  defp update_balance(balance, amount, :subtract), do: %{balance: balance - amount}

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
