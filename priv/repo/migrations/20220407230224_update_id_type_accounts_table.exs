defmodule SimplifiedBankingApi.Repo.Migrations.UpdateIdTypeAccountsTable do
  use Ecto.Migration

  def change do
    alter table("accounts") do
      modify :id, :string
    end
  end
end
