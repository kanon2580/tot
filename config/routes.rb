Rails.application.routes.draw do

  # home
  root 'home#top'
  get '/about' => 'home#about'

  # users
  devise_for :users
  resources :users, only: [:edit, :update], param: :user_id
  resources :users, only: [] do
    resources :comments, only: [:index]
    resources :issues, only: [:index]
  end
  get 'users/:user_id' => 'users#my_page'

  # team_members
  resources :team_members, only: [:new, :create]

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
    resources :tags, only: [:index, :create]
  # teams/issues
    resources :issues, param: :issue_id
    resources :issues, only: [] do
      resources :comments, only: [:create, :edit, :update, :destroy], param: :comment_id
    end
    get '/issues/:issue_id/choice' => 'issues#choice'
    get '/issues/:issue_id/confirm' => 'issues#confirm'
    put '/issues/:issue_id/settled' => 'issues#settled'

  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
