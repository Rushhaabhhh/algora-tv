defmodule AlgoraWeb.YoutubeAuthController do
  use AlgoraWeb, :controller
  plug Ueberauth
  plug :ensure_authenticated

  alias Algora.Accounts.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = conn.assigns.current_user

    case User.create_or_update_youtube_identity(user, auth) do
      {:ok, _identity} ->
        conn
        |> put_flash(:info, "Successfully connected your YouTube account.")
        |> redirect(to: "/channel/settings")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error connecting your YouTube account.")
        |> redirect(to: "/channel/settings")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _failure}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to connect YouTube account.")
    |> redirect(to: "/channel/settings")
  end

  defp ensure_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to connect your YouTube account.")
      |> redirect(to: "/auth/login")
      |> halt()
    end
  end
end
