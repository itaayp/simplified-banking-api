defmodule SimplifiedBankingApi.Accounts.Schemas.Account do
  @moduledoc """
  This schema represents the accounts table.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :id,
    :balance
  ]

  @primary_key {:id, :integer, autogenerate: false}
  schema "accounts" do
    field :balance, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> unique_constraint(:id, name: "accounts_pkey", message: "The account_id is already in use")
  end

  @doc false
  def update_changeset(model, params), do: cast(model, params, @required)
end
