Sengu::Application.routes.draw do
  resources :services, except: [:show] do
    collection do
      post :search
    end

    member do
      get :template_list
    end
  end
  resources :templates, controller: "templates/templates", except: [:index, :show] do
    collection do
      post :element_relation_search_form
      post :element_relation_search

      get :change_order_form
      patch :change_order
    end

    member do
      get :data_select_upon_extension_form
      post :data_select_upon_extension
      post :data_select_upon_extension_preview
      get :download_csv_format     # CSVフォーマット出力
      get :download_description_pdf
    end


    resources :records, controller: "templates/records" do
      collection do
        get :import_csv_form      # CSV一括登録画面
        post :confirm_import_csv  # CSV一括登録確認
        post :import_csv          # CSV一括登録処理
        get :complete_import_csv  # CSV一括登録完了画面
        get :download_csv         # CSV出力
        get :download_rdf         # RDF出力

        post :search_keyword       # キーワード検索

        get :element_description # 項目の説明popover

        post :element_relation_search_form
        post :element_relation_search
        delete :remove_csv_file

        post :add_form
        post :add_namespace_form
        get :sample_field
      end

      member do
        get :display_relation_contents # 選択している関連データの表示
        get :download_file
      end
    end

    resources :elements, controller: "templates/elements", except: [:show, :index] do
      collection do
        get :show
        get :vocabulary_form
        get :other_form
        get :change_form
        get :select_other_element_form
        get :template_form
        get :sort
        patch :change_order
        get :values
        get :vocabulary_values
        get :show_elements
        get :edit_settings
        patch :update_settings
      end

      member do
        patch :move
      end
    end

    resources :settings, controller: "templates/settings", only: [] do
      collection do
        get :set_confirm_entries
        post :update_set_confirm_entries
        get :set_authority
        post :update_set_authority
      end

      member do
        get :edit_location_group
        patch :update_location_group # グループ編集
      end
    end
  end

  namespace :templates, as: :template do
    resources :maps, only: [] do
      collection do
        post :display_search # 住所検索地図表示
        get :display # 地図表示
        get :search_city_id_select # 市町村セレクトの都道府県きりかえ
        post :search_address_location # 住所検索
        get :load_content # 国土地理院の画像を表示するためのアクション
      end
    end
  end

  root to: 'services#index'

  devise_for :users, {
    controllers: {
      registrations: "users",
      sessions: "users/sessions"
    }
  }

  scope :admin, module: :admin do
    resources :regular_expressions

    namespace :vocabulary do
      resources :elements do
        resources :values, controller: "elements/values"
      end
    end
  end

  scope :user_maintenance, module: :user_maintenance do
    resources :sections do
      devise_scope :user do
        resources :users, controller: "sections/users" do
          collection do
            post :inherit_data
            get :inherit_data_form
            get :edit_password
            patch :update_password
          end
        end
      end

      resources :user_groups, controller: "sections/user_groups" do
        member do
          get :user_list
          get :template_list
          get :set_member
          post :search_member
          post :update_set_member
          delete :destroy_member
        end
      end
    end
  end

  mount Vdb::Engine => "/vdb"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
