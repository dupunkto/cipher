defmodule Cipher.Cleanup do
  @moduledoc false
  use GenServer

  require Logger

  @interval :timer.hours(1)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [opts], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    perform_cleanup()
    schedule_cleanup()

    {:ok, nil}
  end

  @impl true
  def handle_info(:cleanup, state) do
    perform_cleanup()
    schedule_cleanup()

    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @interval)
  end

  defp perform_cleanup do
    Cipher.cleanup()
    Logger.info("Ran cleanup.")
  end
end