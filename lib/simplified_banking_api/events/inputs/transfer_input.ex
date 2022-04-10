defmodule SimplifiedBankingApi.Events.Inputs.TransferInput do
  @moduledoc """
  Input validator to the transfer event.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import SimplifiedBankingApi.ChangesetValidation

  @required [:type, :origin, :amount, :destination]

  embedded_schema do
    field :type, :string
    field :origin, :string
    field :amount, :integer
    field :destination, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_inclusion(:type, ["transfer"])
    |> trim(:origin)
    |> trim(:destination)
    |> validate_account_id(:origin)
    |> validate_account_id(:destination)
    |> validate_greater_or_equals_zero(:amount)
  end
end
