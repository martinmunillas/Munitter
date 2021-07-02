defmodule TwitterWeb.PostLive.PostComponent do
  use TwitterWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
      <div class="top_tweet">
        <div class="avatar_container">
          <img class="avatar" src="<%= @post.img %>" alt="<%= @post.username %>" />
        </div>
        <div class="column column-90 post-body">
          <b>@<%= @post.username %></b>
          <br/>
          <%= @post.body %>
          <%= if @post.edited do %>
            <i class="edited">(edited)</i>
          <% end %>
        </div>
      </div>

      <div class="buttons">
        <div class="options">
          <div class="option_container">
            <a href="#" phx-click="like" phx-target="<%= @myself %>" class="option like">
              <i class="far fa-heart"></i> <%= @post.like_count %>
            </a>
          </div>
          <div class="option_container">
            <a href="#" phx-click="retweet" phx-target="<%= @myself %>" class="option retweet">
              <i class="fa fa-retweet"></i> <%= @post.retweet_count %>
            </a>
          </div>
        </div>
        <%= if @current_user && Map.has_key?(@current_user, :id) && @current_user.id == @post.uid do %>
          <div class="edits_post">
            <%= live_patch to: Routes.home_index_path(@socket, :edit, @post.id) do %>
              <i class="fa fa-edit"></i>
            <% end %>
            <%= link to: "#", phx_click: "delete", phx_value_id: @post.id do %>
              <i class="fa fa-trash-alt"></i>
            <% end %>
          </div>
        <% else %>
          <div></div>
        <% end %>
        </div>
      </div>
    """
  end

  def handle_event("like", _, socket) do
    Twitter.Timeline.inc_likes(socket.assigns.post.id)
    {:noreply, socket}
  end

  def handle_event("retweet", _, socket) do
    Twitter.Timeline.inc_retweets(socket.assigns.post.id)
    {:noreply, socket}
  end

end
