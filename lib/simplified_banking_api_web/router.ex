defmodule SimplifiedBankingApiWeb.Router do
  use SimplifiedBankingApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SimplifiedBankingApiWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SimplifiedBankingApiWeb do
    pipe_through :api

    post "/reset", ResetController, :reset
    post "/event", EventsController, :handle_event
    get "/balance", BalanceController, :get_balance
  end
end
