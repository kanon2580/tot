Rails.application.routes.draw do
  get 'team_members/new'
  get 'team_members/create'
  get 'users/my_page'
  get 'users/edit'
  get 'users/update'
  get 'users/index'
  get 'users/show'
  get 'home/top'
  get 'home/about'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
