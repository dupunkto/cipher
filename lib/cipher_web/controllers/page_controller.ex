defmodule CipherWeb.PageController do
  @moduledoc false
  use CipherWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def receive(conn, _params) do
    render(conn, :receive)
  end
end
