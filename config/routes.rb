Rails.application.routes.draw do
  root 'welcome#index'

  # Handle webhooks
  post 'webhook/bamboo'
  post 'webhook/pivotal'

  # Visualisations
  get 'welcome/build'
end
