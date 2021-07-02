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

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

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

  def get_post_with_user(id) do
    query = from p in Post, where: p.id == ^id, join: u in User, as: :user, on: p.user_id == u.id, order_by: [desc: p.id]
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

    [post] = Repo.all(query)
    post
  end

  def inc_likes(id) do
    {1, nil} = from(p in Post, where: p.id == ^id)
    |> Repo.update_all(inc: [like_count: 1])

    post = get_post_with_user(id)
    IO.inspect(post)
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

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    {:ok, post} = %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()


    broadcast({:ok, get_post_with_user(post.id)}, :post_created)
  end

  @doc """
  Updates a post.

  ## Examples

  iex> update_post(post, %{field: new_value})
  {:ok, %Post{}}

  iex> update_post(post, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    {:ok, post} = post
    |> Post.changeset(attrs)
    |> Post.changeset( %{"edited" => true})
    |> Repo.update()


    broadcast({:ok, get_post_with_user(post.id)}, :post_created)
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
    |> broadcast(:post_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

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
