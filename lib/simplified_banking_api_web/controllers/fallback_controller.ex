defmodule SimplifiedBankingApiWeb.FallbackController do
  @moduledoc """
  Fallback controller.
  """

  use SimplifiedBankingApiWeb, :controller

  def call(conn, {:error, :not_found}), do: send_resp(conn, 404, "0")

  def call(conn, {:error, reason}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankingApiWeb.ErrorView)
    |> render("error_reason.json", reason: reason)
  end
end
