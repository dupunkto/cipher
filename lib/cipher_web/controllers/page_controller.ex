defmodule CipherWeb.PageController do
  @moduledoc false
  use CipherWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def receive(conn, _params) do
    render(conn, :receive)
  end

  def send(conn, %{"slug" => slug}) do
    case Cipher.fetch_inbox(slug) do
      {:ok, inbox} ->
        render(conn, :send, inbox: inbox)
      
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> put_view(CipherWeb.ErrorHTML)
        |> render(:"404")
    end
  end

end
