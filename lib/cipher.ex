defmodule Cipher do
  @moduledoc """
  Securely send passphrases and API keys.
  """

  alias Cipher.Repo
  alias Cipher.Key
  alias Cipher.Inbox

  import Ecto.Query

  require Logger

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
    query = active_key_query(id, DateTime.utc_now())

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
    query = active_key_query(id, DateTime.utc_now())

    case Repo.one(query) do
      nil -> {:error, :not_found}
      key when key.uses_left == -1 -> {:ok, key}
      key -> subtract_use(key, query)
    end
  end

  defp active_key_query(id, now) do
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

  @doc """
  Fetches an inbox by slug.
  """
  @spec fetch_inbox(String.t()) :: {:ok, Inbox.t()} | {:error, :not_found}
  def fetch_inbox(slug) do
    case Repo.get_by(Inbox, slug: slug) do
      nil -> {:error, :not_found}
      inbox -> {:ok, inbox}
    end
  end

  @doc """
  Prunes expired and stale keys from the database.
  """
  @spec cleanup() :: :ok
  def cleanup do    
    DateTime.utc_now()
    |> expired_stale_key_query()
    |> Repo.delete_all()
    
    :ok
  end

  defp expired_stale_key_query(now) do
    from(k in Key, where: k.expiry < ^now or k.uses_left == 0)
  end

  @doc """
  Sends a Cipher URL to the specified inbox via SMTP.
  """
  @spec send!(Inbox.t(), String.t(), String.t()) :: term()
  def send!(inbox, subject, url) do
    config = Application.get_env(:cipher, :smtp)
    base_opts = Keyword.delete(config, :sender)

    # This would be safe: (but is broken)
    # tls_opts = [
    #   verify: :verify_peer,
    #   cacerts: :public_key.cacerts_get(),
    #   versions: [:"tlsv1.2", :"tlsv1.3"]
    # ]

    # However, this is easy:
    tls_opts = [verify: :verify_none]

    relay_opts = Keyword.merge(base_opts, [
      sockopts: tls_opts,
      tls_options: tls_opts
    ])

    message = """
    From: #{config[:sender]}\r
    To: #{inbox.email}\r
    Subject: #{subject}\r
    \r
    You have received a new encrypted message: #{url}
    """
        
    email = {config[:sender], [inbox.email], message}

    case :gen_smtp_client.send_blocking(email, relay_opts) do
      {:error, reason} -> raise "Failed to send email, got: #{inspect(reason)}"
      {:error, _, reason} -> raise "Failed to send email, got: #{inspect(reason)}"
      result -> Logger.info("Sent email (from:#{config[:sender]}, to:#{inbox.email}), with: #{inspect(result)}")
    end
  end
end