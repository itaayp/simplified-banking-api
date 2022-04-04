defmodule SimplifiedBankingApi.Repo do
  use Ecto.Repo,
    otp_app: :simplified_banking_api,
    adapter: Ecto.Adapters.Postgres
end
