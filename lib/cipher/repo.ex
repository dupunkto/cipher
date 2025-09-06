defmodule Cipher.Repo do
  use Ecto.Repo,
    otp_app: :cipher,
    adapter: Ecto.Adapters.Postgres
end
