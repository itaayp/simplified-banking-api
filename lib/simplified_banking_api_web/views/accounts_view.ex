defmodule SimplifiedBankingApiWeb.AccountsView do
  @moduledoc """
  Accounts view.
  """

  use SimplifiedBankingApiWeb, :view

  def render("show.json", %{account: %{id: id, balance: balance}}) do
    %{destination: %{id: id, balance: balance}}
  end
end
