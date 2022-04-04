defmodule SimplifiedBankingApiWeb.PageController do
  use SimplifiedBankingApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
