Vdb::Engine.routes.draw do
  resources :templates do
    resources :elements, controller: "templates/elements", only: [:new]

    resources :element_searches, controller: "templates/element_searches", only: [:index] do
      collection do
        post :create_complex_type
        post :create_element
        post :search
        post :find
        post :element_sample_field
        post :complex_sample_field
        get :vocabulary_values
      end
    end
  end

  namespace :vocabulary do
    resources :keywords, only: [:index, :show, :create, :update, :destroy] do
      collection do
        get :configure
        post :search
      end
    end
  end
end

Sengu::Application.routes.draw do
  scope :admin, module: :admin do
    namespace :vocabulary do
      resources :elements do
        collection do
          post :search
          post :create_code_list
        end

        member do
          patch :update_by_vdb
        end
      end
    end
  end
end
