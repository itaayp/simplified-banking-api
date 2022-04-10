defmodule SimplifiedBankingApi.Events.Inputs.DepositInput do
  @moduledoc """
  Input validator to the deposit event.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import SimplifiedBankingApi.ChangesetValidation

  @required [:type, :destination, :amount]

  embedded_schema do
    field :type, :string
    field :destination, :string
    field :amount, :integer, default: 0
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_inclusion(:type, ["deposit"])
    |> trim(:destination)
    |> validate_account_id(:destination)
    |> validate_greater_or_equals_zero(:amount)
  end
end
