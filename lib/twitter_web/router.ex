defmodule TwitterWeb.Router do
  use TwitterWeb, :router

  import TwitterWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TwitterWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  ## Authentication routes
  scope "/", TwitterWeb do
    pipe_through [:browser]

    live "/", HomeLive.Index, :index
  end

  scope "/", TwitterWeb do
    pipe_through [:browser]

    live "/:id/edit", HomeLive.Index, :edit
    live "/:id", HomeLive.Show, :show
    live "/:id/show/edit", HomeLive.Show, :edit
  end

  scope "/", TwitterWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TwitterWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
