defmodule SimplifiedBankingApiWeb.BalanceController do
  @moduledoc """
  Balance controller.

  This module is responsible to handle all incoming requests related to the balance.
  """
  use SimplifiedBankingApiWeb, :controller

  alias SimplifiedBankingApi.{Accounts, ChangesetValidation}
  alias SimplifiedBankingApi.Balance.Inputs.GetBalanceInput

  action_fallback SimplifiedBankingApiWeb.FallbackController

  @doc """
  Gets the account balance
  """
  @spec get_balance(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def get_balance(conn, params) do
    with {:ok, input} <- ChangesetValidation.cast_and_apply(GetBalanceInput, params),
         {:ok, balance} <- Accounts.get_balance(input.account_id) do
      send_resp(conn, 200, "#{balance}")
    else
      error ->
        error
    end
  end
end
