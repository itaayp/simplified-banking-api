defmodule SimplifiedBankingApiWeb.BalanceController do
  @moduledoc """
  Balance controller.

  This module is responsible to handle all incoming requests related to the balance.
  """
  use SimplifiedBankingApiWeb, :controller

  alias SimplifiedBankingApi.Accounts

  action_fallback SimplifiedBankingApiWeb.FallbackController

  @doc """
  Gets the account balance
  """
  @spec get_balance(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def get_balance(conn, %{"account_id" => account_id}) do
    case Accounts.get_balance(account_id) do
      {:ok, balance} -> send_resp(conn, 200, "#{balance}")

      error ->
        error
    end
  end
end
