defmodule Necromancy.Repo do
  use Ecto.Repo,
    otp_app: :necromancy,
    adapter: Ecto.Adapters.SQLite3
end
