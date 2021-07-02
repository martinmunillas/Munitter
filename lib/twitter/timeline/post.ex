defmodule Twitter.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :like_count, :integer, default: 0
    field :retweet_count, :integer, default: 0
    field :user_id, :integer
    field :edited, :boolean, default: false

    timestamps()
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :edited, :user_id])
    |> validate_required([:body, :user_id])
    |> validate_length(:body, min: 2, max: 250)
  end
end
