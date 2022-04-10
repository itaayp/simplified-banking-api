defmodule SimplifiedBankingApi.Events.Inputs.WithdrawInput do
  @moduledoc """
  Input validator to the withdraw event.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import SimplifiedBankingApi.ChangesetValidation

  @required [:type, :origin, :amount]

  embedded_schema do
    field :type, :string
    field :origin, :string
    field :amount, :integer
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_inclusion(:type, ["withdraw"])
    |> trim(:origin)
    |> validate_account_id(:origin)
    |> validate_greater_or_equals_zero(:amount)
  end
end
