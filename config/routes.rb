Rails.application.routes.draw do
  devise_for :users
  root 'posts#index'
  resources :posts,  only: [:index, :show]
  resources :brands, only: [:index, :show]
  resources :accounts, only: [:index, :show] do
    resources :favorites, only: [:create, :destroy]
  end
  resources :hash_tags, only: [:index]
  resources :talk_posts, only: [:index, :show]
  resources :landing_pages, only: [:index, :show]
  resources :rich_menus, only: [:index, :show] do
    resources :rich_menu_contents, only: [] do
      get 'talk_flows', to: 'talk_flows#index'
      post 'talk_flows/show_next_flow', to: 'talk_flows#show_next_flow'
    end
  end
  post "append_modal", to: "brands#append_modal"
end
