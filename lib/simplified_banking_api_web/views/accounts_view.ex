defmodule SimplifiedBankingApiWeb.AccountsView do
  @moduledoc """
  Accounts view.
  """

  use SimplifiedBankingApiWeb, :view

  def render("deposit.json", %{account: %{id: id, balance: balance}}) do
    %{destination: %{id: id, balance: balance}}
  end

  def render("withdraw.json", %{account: %{id: id, balance: balance}}) do
    %{origin: %{id: id, balance: balance}}
  end

  def render("transfer.json", %{origin_account: origin, destination_account: destination}) do
    %{origin: %{id: origin.id, balance: origin.balance}, destination: %{id: destination.id, balance: destination.balance}}
  end
end
