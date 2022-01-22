Rails.application.routes.draw do
  root 'upload#index'
  get 'upload/index'
  post 'upload/convert'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
