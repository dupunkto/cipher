defmodule Cipher.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :cipher,
    adapter: Ecto.Adapters.Postgres
end
