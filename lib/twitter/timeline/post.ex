defmodule Twitter.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :like_count, :integer, default: 0
    field :retweet_count, :integer, default: 0
    field :username, :string, default: "MartinMunilla"

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, min: 2, max: 150)
  end
end
