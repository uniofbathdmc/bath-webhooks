Rails.application.routes.draw do
  root 'welcome#index'

  post 'webhook/bamboo'
  post 'webhook/pivotal'
end
