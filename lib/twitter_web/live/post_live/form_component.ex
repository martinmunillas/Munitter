defmodule TwitterWeb.PostLive.FormComponent do
  use TwitterWeb, :live_component

  alias Twitter.Timeline

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Timeline.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, Map.merge(post_params, %{"user_id" => socket.assigns.current_user.id}))
  end

  defp save_post(socket, :edit, post_params) do
    case Timeline.update_post(socket.assigns.post, post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Timeline.create_post(post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
