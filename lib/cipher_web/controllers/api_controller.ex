defmodule CipherWeb.APIController do
  @moduledoc false
  use CipherWeb, :controller

  def create_key(conn, %{"expiry" => hours, "uses" => uses}) do
    expiry =
      DateTime.utc_now()
      |> DateTime.add(hours * 3600, :second)
      |> DateTime.truncate(:second)

    case Cipher.create_key(expiry, uses) do
      {:ok, %{id: id, key: key}} ->
        json(conn, %{id: id, key: Base.encode64(key)})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Internal server error."})
    end
  end

  def meta_key(conn, %{"id" => key_id}) do
    case Cipher.peek_key(key_id) do
      {:ok, %Cipher.Key{} = key} ->
        json(conn, Map.take(key, [:uses_left, :expiry]))

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not found."})
    end
  end

  def fetch_key(conn, %{"id" => key_id}) do
    case Cipher.fetch_key(key_id) do
      {:ok, %Cipher.Key{key: key}} ->
        json(conn, %{key: Base.encode64(key)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not found."})
    end
  end
end