defmodule SimplifiedBankingApi.Balance.Inputs.GetBalanceInput do
  @moduledoc """
  Input validator to get the account balance.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required [:account_id]

  embedded_schema do
    field :account_id, :integer
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
