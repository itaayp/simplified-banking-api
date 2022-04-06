defmodule SimplifiedBankingApiWeb.ResetController do
  @moduledoc """
  Reset controller.

  This module is responsible to handle all the incoming requests related to reset the API.
  """
  use SimplifiedBankingApiWeb, :controller

  alias SimplifiedBankingApi.Accounts

  action_fallback SimplifiedBankingApiWeb.FallbackController

  @doc """
  Resets all the API data.
  """
  @spec reset(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def reset(conn, _params) do
    case Accounts.reset_data() do
      {:ok, :success} -> send_resp(conn, 200, "OK")
      error -> error
    end
  end
end
