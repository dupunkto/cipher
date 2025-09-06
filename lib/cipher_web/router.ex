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
  end

  scope "/api", CipherWeb do
    pipe_through :api
    post "/keys", ApiController, :create_key
    get "/keys/:id", ApiController, :fetch_key
  end
end
