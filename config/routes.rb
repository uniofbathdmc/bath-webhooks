Rails.application.routes.draw do
  resources :build_infos

  root 'welcome#index'

  # Handle webhooks
  post 'webhook/bamboo'
  post 'webhook/pivotal'

  # Visualisations
  get 'welcome/build'
  get 'welcome/grouped'
end
