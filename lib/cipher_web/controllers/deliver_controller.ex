defmodule CipherWeb.DeliverController do
  @moduledoc false
  use CipherWeb, :controller

  def send_email(conn, %{"slug" => slug, "subject" => subject, "url" => url}) do
    case Cipher.fetch_inbox(slug) do
      {:ok, inbox} ->
        Cipher.send!(inbox, subject, url) |> dbg()
        json(conn, %{success: true})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Inbox not found"})
    end
  end
end