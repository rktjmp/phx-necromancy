defmodule NecromancyWeb.NecroLive do
  defmodule Form do
    use Ecto.Schema

    embedded_schema do
      field(:name)
    end

    def changeset(params) do
      %Form{}
      |> Ecto.Changeset.cast(params, [:name])
      |> Ecto.Changeset.validate_required([:name])
      |> Ecto.Changeset.validate_format(:name, ~r/[0-9] [a-z]+/,
        message: "Name must match 0-9 a-Z"
      )
    end
  end

  use NecromancyWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        event_ran?: false,
        connected?: connected?(socket),
        changeset: Form.changeset(%{}),
        task: nil,
        bytes: nil
      )

    {:ok, socket}
  end

  def handle_event("start_process", _, socket) do
    task =
      Task.async(fn ->
        Process.sleep(3000)
        {:ok, :crypto.strong_rand_bytes(64)}
      end)

    socket = assign(socket, task: task)
    {:noreply, socket}
  end

  # you can match on task ref if you have a reason to
  def handle_info({ref, {:ok, bytes}}, %{assigns: %{task: %{ref: ref}}} = socket) do
    socket = assign(socket, task: nil, bytes: bytes)
    {:noreply, socket}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, socket) do
    # probably do something smart here
    {:noreply, socket}
  end

  def handle_event("run_event", _, socket) do
    socket = assign(socket, event_ran?: true)
    {:noreply, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    changeset =
      Form.changeset(params)
      |> Map.put(:action, :validate)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    changeset =
      Form.changeset(params)
      |> Map.put(:action, :validate)

    socket = assign(socket, changeset: changeset)

    socket =
      case changeset do
        %{valid?: true} ->
          put_flash(socket, :info, "nice one!")

        _ ->
          put_flash(socket, :error, "dang it!")
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <section>
      <p :if={@connected?}>
        I am ALIVE. <button phx-click="start_process">Run long task</button>
        <%= inspect(@task) %>
        <%= inspect(@bytes) %>
      </p>

      <p :if={not @connected?}>
        I am DEAD.
      </p>

      <p :if={not @connected?}>
        <button type="button" data-connect-liveview="click">Just Connect</button>
      </p>

      <button type="button" phx-click="run_event">
        Run an action
      </button>
      <p>Event has been run?: <%= @event_ran? %></p>

      Access form to connect
      <.form
        :let={f}
        data-connect-liveview="input"
        for={@changeset}
        phx-change="validate"
        phx-submit="submit"
        phx-page-loading="false"
      >
        <%= text_input(f, :name) %>
        <%= error_tag(f, :name) %>
      </.form>
    </section>
    """
  end
end
