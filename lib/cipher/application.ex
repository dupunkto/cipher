defmodule Cipher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CipherWeb.Telemetry,
      Cipher.Repo,
      {DNSCluster, query: Application.get_env(:cipher, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Cipher.PubSub},
      # Start a worker by calling: Cipher.Worker.start_link(arg)
      # {Cipher.Worker, arg},
      # Start to serve requests, typically the last entry
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
