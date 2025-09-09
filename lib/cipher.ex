defmodule Cipher do
  @moduledoc """
  Securely send passphrases and API keys.
  """

  alias Cipher.Repo
  alias Cipher.Key

  import Ecto.Query

  @doc """
  Creates a new encryption key.
  """
  @spec create_key(DateTime.t(), integer()) :: {:ok, Key.t()} | {:error, term()}
  def create_key(expiry, uses) do
    Repo.insert(%Key{
      id: generate_id(),
      key: generate_key(),
      expiry: expiry,
      uses_left: uses
    })
  end

  defp generate_id do
    timestamp = System.system_time(:second) |> Integer.to_string(36)
    random = :crypto.strong_rand_bytes(8) |> Base.encode32(case: :lower, padding: false)
    "#{timestamp}-#{random}"
  end

  defp generate_key do
    :crypto.strong_rand_bytes(32)
  end

  @doc """
  Fetches an existing (usable and non-expired) encryption key without consuming it.
  """
  @spec peek_key(String.t()) :: {:ok, Key.t()} | {:error, term()}
  def peek_key(id) do
    query = key_query(id, DateTime.utc_now())

    case Repo.one(query) do
      nil -> {:error, :not_found}
      key -> {:ok, key}
    end
  end

  @doc """
  Fetches an existing (usable and non-expired) encryption key and
  substracts a use from it.
  """
  @spec fetch_key(String.t()) :: {:ok, Key.t()} | {:error, term()}
  def fetch_key(id) do
    query = key_query(id, DateTime.utc_now())

    case Repo.one(query) do
      nil -> {:error, :not_found}
      key when key.uses_left == -1 -> {:ok, key}
      key -> subtract_use(key, query)
    end
  end

  defp key_query(id, now) do
    Key
    |> where([k], k.id == ^id)
    |> where([k], k.expiry > ^now)
    |> where([k], k.uses_left > 0 or k.uses_left == -1)
  end

  defp subtract_use(key, query) do
    case Repo.update_all(query, inc: [uses_left: -1]) do
      {1, _} -> {:ok, key}
      {0, _} -> {:error, :invalid_usage}
    end
  end
end