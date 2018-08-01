Rails.application.routes.draw do
  resources :build_infos

  root 'welcome#index'

  # Handle webhooks
  post 'webhook/bamboo'
  post 'webhook/pivotal'
  post 'webhook/github'
  post 'webhook/gitlab'

  # Visualisations
  get 'welcome/build'
  get 'welcome/repo_statuses'
end
