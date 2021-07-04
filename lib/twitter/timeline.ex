defmodule Twitter.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Twitter.Repo

  alias Twitter.Timeline.Post
  alias Twitter.Accounts.User

  @doc """
  Returns the list of posts.
  """
  def list_posts do
    query = from p in Post, join: u in User, as: :user, on: p.user_id == u.id, order_by: [desc: p.id]
    query = from [p, u] in query,
                select: %{
                  id: p.id,
                  body: p.body,
                  edited: p.edited,
                  like_count: p.like_count,
                  retweet_count: p.retweet_count,
                  username: u.name,
                  uid: u.id,
                  img: u.image
                }
    Repo.all(query)
  end

  def get_post_with_user(id) when is_integer(id)  do
    query = from p in Post, where: p.id == ^id, join: u in User, as: :user, on: p.user_id == u.id
    query = from [p, u] in query,
                select: %{
                  id: p.id,
                  body: p.body,
                  edited: p.edited,
                  like_count: p.like_count,
                  retweet_count: p.retweet_count,
                  username: u.name,
                  uid: u.id,
                  img: u.image
                }

    Repo.one(query)
  end

  def get_post_with_user(post) do
    query = from u in User, where: ^post.user_id == u.id, select: [:name, :id, :image]

    user = Repo.one(query)

    post
      |> Map.merge(%{username: user.name, uid: user.id, img: user.image})
  end

  def inc_likes(id) do
    {1, nil} = from(p in Post, where: p.id == ^id)
    |> Repo.update_all(inc: [like_count: 1])

    post = get_post_with_user(id)
    broadcast({:ok, post}, :post_updated)
  end

  def inc_retweets(id) do
    {1, nil} = from(p in Post, where: p.id == ^id)
    |> Repo.update_all(inc: [retweet_count: 1])

    post = get_post_with_user(id)

    broadcast({:ok, post}, :post_updated)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.
  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.
  """
  def create_post(attrs \\ %{}) do
    {:ok, post} = %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()


    broadcast({:ok, get_post_with_user(post)}, :post_created)
  end

  @doc """
  Updates a post.
  """
  def update_post(%Post{} = post, attrs) do
    {:ok, post} = post
    |> Post.changeset(attrs)
    |> Post.changeset( %{"edited" => true})
    |> Repo.update()


    broadcast({:ok, get_post_with_user(post)}, :post_updated)
  end

  @doc """
  Deletes a post.

   """
  def delete_post(%Post{} = post) do
    {:ok, post} = Repo.delete(post)

    broadcast({:ok, get_post_with_user(post)}, :post_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.
  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Twitter.PubSub, "posts")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(Twitter.PubSub, "posts", {event, post})
    {:ok, post}
  end
end
