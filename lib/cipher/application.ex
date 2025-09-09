defmodule Cipher.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CipherWeb.Telemetry,
      Cipher.Repo,
      {Phoenix.PubSub, name: Cipher.PubSub},
      Cipher.Cleanup,
      CipherWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cipher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CipherWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
