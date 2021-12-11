defmodule PasswordGeneratorWeb.PageLive.PasswordModuleComponent do
  use PasswordGeneratorWeb, :live_component
  alias PasswordGenerator.Password

  @impl true
  def mount(socket) do
    pw_length = 12
    include_number? = false
    include_special_symbol? = false

    socket =
      socket
      |> assign(include_number?: include_number?)
      |> assign(include_special_symbol?: include_special_symbol?)
      |> assign(length: pw_length)

    if connected?(socket) do
      {:ok, password} = Password.generate(pw_length, include_number?, include_special_symbol?)

      {
        :ok,
        socket
        |> assign(password: password)
      }
    else
      {
        :ok,
        socket
        |> assign(password: "")
      }
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4 mt-6 border-2 border-indigo-500 rounded-lg bg-indigo-50">
      <div class="">
        <%= text_input :password, :input_field, id: "copy-password-#{@module_id}", class: "shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md", value: @password, readonly: true %>
        <div phx-hook="copyPasswordToClipboard" id={"copy-btn-#{@module_id}"} data-module-id={@module_id} type="button" class="mt-2 cursor-pointer inline-flex items-center px-2.5 py-1.5 border border-transparent text-xs font-medium rounded shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
          Copy Password
        </div>
      </div>

      <form phx-change="change-password-input" phx-target={@myself} phx-submit="generate-new-password" id={@module_id}>


        <div class="grid w-full grid-cols-2 gap-x-4">
          <div class="flex flex-col mt-2 text-sm">

            <div class="flex flex-col mt-6 space-y-2">
              <div class="text-sm">Password Length</div>
              <div class="flex items-center space-x-4">

                <%= text_input :password, :length_input, id: "text-input-#{@module_id}", value: @length, phx_debounce: 0, min: 6, max: 64, class: "w-16 shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md" %>

                <%= range_input :password, :length_range, id: "range-input-#{@module_id}", class: "w-full cursor-pointer bg-indigo-300 overflow-hidden rounded-lg appearance-none", value: @length, phx_debounce: 0, min: 6, max: 64 %>
              </div>
            </div>

            <label class="flex items-center font-normal cursor-pointer group">
              <%= checkbox(:password, :include_number?, value: @include_number?, id: "checkbox-num-input-#{@module_id}", class: "group-hover:border-2 group-hover:border-indigo-500 focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded") %>
              <span class="ml-2 select-none group-hover:text-gray-700">Includes Numbers?</span>
            </label>

            <label class="flex items-center font-normal cursor-pointer group">
              <%= checkbox(:password, :include_special_symbol?, value: @include_special_symbol?, id: "checkbox-symbol-input-#{@module_id}", class: "group-hover:border-2 group-hover:border-indigo-500 focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded") %>
              <span class="ml-2 select-none group-hover:text-gray-700">Includes Special Symbols?</span>
            </label>
          </div>

          <div class="place-self-end">
            <button type="submit"
              class="flex items-center px-6 py-3 mt-4 text-base font-medium text-center text-white bg-indigo-600 border border-transparent rounded-md shadow-sm h-min hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">Generate
              New Password
            </button>
          </div>
        </div>

      </form>
    </div>

    """
  end

  @impl true
  def handle_event(
        "change-password-input",
        %{
          "_target" => ["password", "length_input"],
          "password" => %{
            "length_input" => length
          }
        },
        socket
      ) do
    handle_length_change(socket, length)
  end

  def handle_event(
        "change-password-input",
        %{
          "_target" => ["password", "length_range"],
          "password" => %{
            "length_range" => length
          }
        },
        socket
      ) do
    handle_length_change(socket, length)
  end

  def handle_event(
        "change-password-input",
        %{
          "_target" => ["password", "include_number?"],
          "password" => %{
            "include_number?" => include_number?
          }
        },
        socket
      ) do
    {:ok, password} =
      Password.generate(
        socket.assigns.length,
        include_number? |> determine_boolean(),
        socket.assigns.include_special_symbol? |> determine_boolean()
      )

    {:noreply,
     socket
     |> assign(password: password)
     |> assign(include_number?: include_number?)}
  end

  def handle_event(
        "change-password-input",
        %{
          "_target" => ["password", "include_special_symbol?"],
          "password" => %{
            "include_special_symbol?" => include_special_symbol?
          }
        },
        socket
      ) do
    {:ok, password} =
      Password.generate(
        socket.assigns.length,
        socket.assigns.include_number? |> determine_boolean(),
        include_special_symbol? |> determine_boolean()
      )

    {:noreply,
     socket
     |> assign(password: password)
     |> assign(include_special_symbol?: include_special_symbol?)}
  end

  def handle_event("generate-new-password", %{}, socket) do
    {:ok, password} =
      Password.generate(
        socket.assigns.length,
        socket.assigns.include_number? |> determine_boolean(),
        socket.assigns.include_special_symbol? |> determine_boolean()
      )

    {:noreply,
     socket
     |> assign(password: password)}
  end

  defp handle_length_change(socket, length) do
    include_number? = socket.assigns.include_number? |> determine_boolean()
    include_special_symbol? = socket.assigns.include_special_symbol? |> determine_boolean()

    case Integer.parse(length) do
      :error ->
        {:noreply,
         socket
         |> put_flash(:error, "Not a number")}

      # Ensure min length
      {length, _} when length >= 6 ->
        {:ok, password} =
          Password.generate(
            length,
            include_number?,
            include_special_symbol?
          )

        {:noreply,
         socket
         |> clear_flash()
         |> assign(password: password)
         |> assign(length: length)}

      # If not min, default to min
      _ ->
        {:ok, password} =
          Password.generate(
            6,
            include_number?,
            include_special_symbol?
          )

        {:noreply,
         socket
         |> put_flash(:error, "Should be at least 6")
         |> assign(password: password)
         |> assign(length: 6)}
    end
  end

  defp determine_boolean(true), do: true
  defp determine_boolean(false), do: false
  defp determine_boolean("true"), do: true
  defp determine_boolean(_), do: false
end
