Rails.application.routes.draw do
  devise_for :users
  get 'posts/csv_download', as: 'post_csv_download', defaults: { format: :csv }
  resources :posts,  only: [:index, :show]
  resources :brands, only: [:index, :show]
  get 'accounts/csv_download', as: 'account_csv_download', defaults: { format: :csv }
  resources :accounts, only: [:index, :show] do
    resources :favorites, only: [:create, :destroy]
  end
  get 'hash_tags/csv_download', as: 'hash_tag_csv_download', defaults: { format: :csv }
  resources :hash_tags, only: [:index]
  get 'talk_posts/csv_download', as: 'talk_post_csv_download', defaults: { format: :csv }
  resources :talk_posts, only: [:index, :show]
  get 'landing_pages/csv_download', as: 'landing_page_csv_download', defaults: { format: :csv }
  resources :landing_pages, only: [:index, :show]
  get 'rich_menus/csv_download', as: 'rich_menu_csv_download', defaults: { format: :csv }
  resources :rich_menus, only: [:index, :show] do
    resources :rich_menu_contents, only: [] do
      get 'talk_flows', to: 'talk_flows#index'
      post 'talk_flows/show_next_flow', to: 'talk_flows#show_next_flow'
    end
  end
  post "append_modal", to: "brands#append_modal"
  root 'top#index'
end
