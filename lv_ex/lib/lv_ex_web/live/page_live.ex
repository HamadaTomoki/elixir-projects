defmodule LvExWeb.PageLive do
  use LvExWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="phx-hero">
      <h1><%= gettext("Welcome to %{name}!", name: "Phoenix") %></h1>
      <p>Peace of mind from prototype to production</p>

      <form phx-change="suggest" phx-submit="search">
        <input
          type="text"
          name="q"
          value={@query}
          placeholder="Live dependency search"
          list="results"
          autocomplete="off"
        />
        <datalist id="results">
          <%= for {app, _vsn} <- @results do %>
            <option value={app}><%= app %></option>
          <% end %>
        </datalist>
        <button type="submit" phx-disable-with="Searching...">Go to Hexdocs</button>
      </form>
    </section>

    <section class="row">
      <article class="column">
        <h2>Resources</h2>
        <ul>
          <li>
            <a href="https://hexdocs.pm/phoenix/overview.html">Guides &amp; Docs</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix">Source</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix/blob/v1.5/CHANGELOG.md">
              v1.5 Changelog
            </a>
          </li>
        </ul>
      </article>
      <article class="column">
        <h2>Help</h2>
        <ul>
          <li>
            <a href="https://elixirforum.com/c/phoenix-forum">Forum</a>
          </li>
          <li>
            <a href="https://webchat.freenode.net/?channels=elixir-lang">
              #elixir-lang on Freenode IRC
            </a>
          </li>
          <li>
            <a href="https://twitter.com/elixirphoenix">Twitter @elixirphoenix</a>
          </li>
          <li>
            <a href="https://elixir-slackin.herokuapp.com/">Elixir on Slack</a>
          </li>
        </ul>
      </article>
    </section>
    """
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not LiveViewStudioWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
