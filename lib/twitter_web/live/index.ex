defmodule TwitterWeb.HomeLive.Index do
  use TwitterWeb, :live_view

  alias TwitterWeb.UserAuth
  alias Twitter.Timeline
  alias Twitter.Timeline.Post

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    current_user = UserAuth.get_user_from_session(session)

    {:ok,
    socket
    |> assign(
      posts: list_posts(),
      should_refresh: false,
      post: %Post{},
      editable_post: nil,
      current_user: current_user,
      removed_tweets: []
    )
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(
      page_title: "Edit Tweet",
      editable_post: Timeline.get_post!(id)
    )
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Home")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, assign(socket, :posts, list_posts())}
  end


  def handle_event("refresh", _, socket) do
    {:noreply, socket
                |> assign(
                  should_refresh: false,
                  posts: list_posts()
                )}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    if !socket.assigns.current_user || !Map.has_key?(socket.assigns.current_user, :id) || post.uid != socket.assigns.current_user.id do
      {:noreply, assign(socket, should_refresh: true)}
    else
      posts = socket.assigns.posts
      {:noreply, assign(socket,
                  posts: [post | posts])
      }
    end
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    posts = Enum.map(socket.assigns.posts, fn opost -> if opost.id == post.id do post else opost end end)
    {:noreply, assign(socket, posts: posts)}
  end

  @impl true
  def handle_info({:post_deleted, post}, socket) do
    if socket.assigns.current_user && Map.has_key?(socket.assigns.current_user, :id) && post.uid == socket.assigns.current_user.id do
      {:noreply, assign(socket, posts: list_posts())}
    else
      removed = socket.assigns.removed_tweets
      {:noreply, assign(socket, removed_tweets: [post.id | removed])}
    end
  end

  def list_posts do
    Timeline.list_posts()
  end

end
