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
  get 'mypage/:user_id' => 'users#my_page', as: "mypage"
  get 'mypage/:user_id/edit' => 'users#edit', as: "edit_user"

  # team_members
  resources :team_members, only: [:create]
  get 'mypage/team_members/new' => 'team_members#new', as: "new_team_member"

  # search
  get 'teams/:team_id/issues/search' => 'search#issue', as: "team_issues_search"
  get 'teams/:team_id/users/search' => 'search#user', as: "team_users_search"

  # teams
  resources :teams, only: [:show], param: :team_id
  resources :teams, only: [] do
  # teams/users
    resources :users, only: [:index] do
      resources :comments, only: [:index]
      resources :issues, only: [:index]
    end
    get 'mypage/:user_id' => 'users#my_page', as: "mypage"
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
