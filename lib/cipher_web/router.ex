defmodule CipherWeb.Router do
  @moduledoc false
  use CipherWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CipherWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CipherWeb do
    pipe_through :browser
    get "/", PageController, :home
    get "/receive", PageController, :receive
    get "/send/:slug", PageController, :send
  end

  scope "/", CipherWeb do
    pipe_through :api
    post "/api/keys", APIController, :create_key
    get "/api/keys/:id", APIController, :fetch_key
    get "/api/keys/:id/meta", APIController, :meta_key
    post "/send/:slug", DeliverController, :send_email
  end
end
