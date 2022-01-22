Rails.application.routes.draw do
  get 'upload/index'
  post 'upload/convert'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'upload#index'
end
