defmodule SimplifiedBankingApiWeb.EventsController do
  @moduledoc """
  Events controller.

  This module is responsible to handle all incoming events.
  """
  use SimplifiedBankingApiWeb, :controller

  alias SimplifiedBankingApi.Accounts

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
  def handle_event(conn, %{"type" => "deposit", "destination" => account_id} = params) do
    case Accounts.deposit(account_id, Map.get(params, "amount", 0)) do
      {:ok, account} ->
        conn
        |> put_view(AccountsView)
        |> put_status(201)
        |> render("show.json", %{account: account})

      error ->
        error
    end
  end
end
