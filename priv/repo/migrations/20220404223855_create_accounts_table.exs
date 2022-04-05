defmodule SimplifiedBankingApi.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table("accounts", primary_key: false) do
      add :id, :integer, primary_key: true
      add :balance, :integer, default: 0, null: false

      timestamps()
    end
  end
end
