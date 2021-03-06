Rails.application.routes.draw do

  # home
  root 'home#top'
  get '/about' => 'home#about'

  # users
  devise_for :users
  resources :users, only: [:update], param: :user_id
  resources :users, only: [] do
    resources :comments, only: [:index]
    resources :issues, only: [:index]
  end
  get 'mypage/:user_id' => 'users#mypage', as: "mypage"
  get 'mypage/:user_id/edit' => 'users#edit', as: "edit_user"
  post 'mypage/:user_id/join_team' => 'users#join_team', as: "join_team"

  # search
  get 'teams/:team_id/issues/search' => 'search#issues', as: "team_issues_search"
  get 'teams/:team_id/users/search' => 'search#users', as: "team_users_search"
  get 'teams/:team_id/tags/search' => 'search#tags', as: "team_tags_search"

  # teams
  resources :teams, only: [:show], param: :team_id
  resources :teams, only: [] do
  # teams/users
    resources :users, only: [:index, :show], param: :user_id
    resources :users, only: [] do
      resources :comments, only: [:index]
      resources :issues, only: [:index]
    end
  # teams/tags
    resources :tags, only: [:index, :create] do
      resources :issues, only: [:index]
    end
  # teams/issues
    resources :issues, param: :issue_id
    resources :issues, only: [] do
      resources :comments, only: [:create, :edit, :update, :destroy], param: :comment_id
      resource :likes, only: [:create, :destroy]
    end
    get '/issues/:issue_id/choice' => 'issues#choice', as: "choice"
    get '/issues/:issue_id/confirm' => 'issues#confirm', as: "confirm"
    put '/issues/:issue_id/settled' => 'issues#settled', as: "settled"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
