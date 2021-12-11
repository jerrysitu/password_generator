defmodule PasswordGeneratorWeb.PageLive do
  use PasswordGeneratorWeb, :live_view

  alias PasswordGeneratorWeb.PageLive.PasswordModuleComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(password_modules: [1])}
  end

  @impl true
  def handle_event("add-new-module", _, socket) do
    password_modules = socket.assigns.password_modules

    next_module_id = length(password_modules) + 1

    password_modules = [next_module_id | password_modules]

    {:noreply, socket |> assign(password_modules: password_modules)}
  end
end
