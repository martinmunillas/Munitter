defmodule TwitterWeb.HomeLive.Index do
  use TwitterWeb, :live_view

  alias Twitter.Timeline
  alias Twitter.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    {:ok,
    socket
    # |> TwitterWeb.UserAuth.fetch_current_user(%{})
    |> assign(:posts, list_posts())
    |> assign(:should_refresh, false),
    temporary_assigns: [posts: []]
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tweet")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tweet")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Feed")
    |> assign(:post, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, assign(socket, :posts, list_posts())}
  end


  def handle_event("refresh", _, socket) do
    {:noreply, socket
               |> assign(:should_refresh, false)
               |> assign(:posts, list_posts())}
  end

  @impl true
  def handle_info({:post_created, _post}, socket) do
    {:noreply, assign(socket, :should_refresh, true)}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  @impl true
  def handle_info({:post_deleted, _post}, socket) do
    {:noreply, assign(socket, :should_refresh, true)}
  end

  def list_posts do
    Timeline.list_posts()
  end

end
