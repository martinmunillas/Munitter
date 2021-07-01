defmodule TwitterWeb.PostLive.PostComponent do
  use TwitterWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
      <div class="top_tweet">
        <div class="avatar_container">
          <img class="avatar" src="https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/loki-poster-fotogramas-1617632148.jpg?crop=1.00xw:0.338xh;0,0.253xh&resize=1200:*" alt="<%= @post.username %>" />
        </div>
        <div class="column column-90 post-body">
          <b>@<%= @post.username %></b>
          <br/>
          <%= @post.body %>
          <%= if @post.edited do %>
            <i>(edited)</i>
          <% end %>
        </div>
      </div>

      <div class="buttons">
        <div class="options">
          <div class="option">
            <a href="#" phx-click="like" phx-target="<%= @myself %>">
              <i class="far fa-heart"></i> <%= @post.like_count %>
            </a>
          </div>
          <div class="option">
            <a href="#" phx-click="retweet" phx-target="<%= @myself %>">
              <i class="fa fa-retweet"></i> <%= @post.retweet_count %>
            </a>
          </div>
        </div>
        <div class="edits_post">
          <%= live_patch to: Routes.home_index_path(@socket, :edit, @post.id) do %>
            <i class="fa fa-edit"></i>
          <% end %>
          <%= link to: "#", phx_click: "delete", phx_value_id: @post.id do %>
            <i class="fa fa-trash-alt"></i>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("like", _, socket) do
    Twitter.Timeline.inc_likes(socket.assigns.post)
    {:noreply, socket}
  end

  def handle_event("retweet", _, socket) do
    Twitter.Timeline.inc_retweets(socket.assigns.post)
    {:noreply, socket}
  end

end
