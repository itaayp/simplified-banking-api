defmodule SimplifiedBankingApiWeb.ResetController do
  @moduledoc """
  Reset controller.

  This module is responsible to handle all the incoming requests related to reset the API.
  """
  use SimplifiedBankingApiWeb, :controller

  alias SimplifiedBankingApi.Accounts

  @doc """
  Resets all the API data.
  """
  @spec reset(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def reset(conn, _params) do
    case Accounts.reset_data() do
      {:ok, :success} -> put_status(conn, 200)
      error -> error
    end
  end
end
