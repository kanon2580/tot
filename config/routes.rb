Rails.application.routes.draw do

  # home
  root 'home#top'
  get '/about' => 'home#about'

  # users
  devise_for :users
  resources :users, only: [:edit, :update] do
    resources :comments, only: [:index]
    resources :issues, only: [:index]
  end
  get 'users/:id' => 'users#my_page'

  # team_members
  resources :tesm_members, only: [:new, :create]

  # teams
  resources :team, only: [:show] do
  # teams/users
    resources :users, only: [:index, :show] do
      resources :comments, only: [:index]
      resources :issues, only: [:index]
    end
  # teams/tags
    resources :tags, only: [:index, :create]
  # teams/issues
    resources :issue do
      resources :comments, only: [:create, :edit, :update, :destroy]
    end
    get '/issues/:id/choice' => 'issues#choice'
    get '/issues/:id/confirm' => 'issues#confirm'
    put 'issues/:id/settled' => 'issues#settled'

  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
