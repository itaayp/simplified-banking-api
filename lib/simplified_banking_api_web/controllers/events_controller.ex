defmodule SimplifiedBankingApiWeb.EventsController do
  @moduledoc """
  Events controller.

  This module is responsible to handle all incoming events.
  """
  use SimplifiedBankingApiWeb, :controller

  alias SimplifiedBankingApi.{Accounts, ChangesetValidation}
  alias SimplifiedBankingApi.Events.Inputs.{DepositInput, WithdrawInput}
  alias SimplifiedBankingApiWeb.AccountsView

  action_fallback SimplifiedBankingApiWeb.FallbackController

  @doc """
  Handle events.
  An event can be one of these possible types:
  - deposit
  - withdraw
  - transfer
  """
  @spec handle_event(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def handle_event(conn, %{"type" => "deposit"} = params) do
    with {:ok, input} <- ChangesetValidation.cast_and_apply(DepositInput, params),
         {:ok, account} <- Accounts.deposit(input.destination, Map.get(input, :amount, 0)) do
      conn
      |> put_view(AccountsView)
      |> put_status(201)
      |> render("deposit.json", %{account: account})
    else
      error ->
        error
    end
  end

  def handle_event(conn, %{"type" => "withdraw"} = params) do
    with {:ok, input} <- ChangesetValidation.cast_and_apply(WithdrawInput, params),
         {:ok, account} <- Accounts.withdraw(input.origin, Map.get(input, :amount)) do
      conn
      |> put_view(AccountsView)
      |> put_status(201)
      |> render("withdraw.json", %{account: account})
    else
      error ->
        error
    end
  end

  def handle_event(
        conn,
        %{"type" => "transfer", "origin" => _, "amount" => _, "destination" => _} = params
      ) do
    case Accounts.transfer(
           Map.get(params, "origin"),
           Map.get(params, "amount"),
           Map.get(params, "destination")
         ) do
      {:ok, origin_account, destination_account} ->
        conn
        |> put_view(AccountsView)
        |> put_status(201)
        |> render("transfer.json", %{
          origin_account: origin_account,
          destination_account: destination_account
        })

      error ->
        error
    end
  end
end
