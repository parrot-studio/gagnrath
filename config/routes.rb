Gagnrath::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root to: 'welcome#index'
  root 'root#index'

  put  'update' => 'root#update'
  get  'status' => 'root#check_status'
  post 'status' => 'root#check_status'
  get  'sr'     => 'root#menu', as: :menu
  get  'latest' => 'root#latest'
  post 'latest' => 'root#latest'
  put  'cutin'  => 'root#cutin'
  delete  'union_history' => 'root#delete_union_history'

  get    't'                 => 'timeline#index',     as: :timeline
  get    't/d/:date'         => 'timeline#revs',      as: :timeline_revs
  get    't/d/:date/r/:rev'  => 'timeline#situation', as: :timeline_situation
  delete 't/d/:date/r/:rev'  => 'timeline#destroy'
  get    't/d/:date/f/:fort' => 'timeline#fort',      as: :timeline_for_fort
  get    't/d/:date/g/:name' => 'timeline#guild',     as: :timeline_for_guild
  get    't/d/:date/u'       => 'timeline#union_select',   as: :timeline_union
  post   't/d/:date/u'       => 'timeline#union_redirect'
  get    't/d/:date/u/:code' => 'timeline#union',          as: :timeline_for_union
  get    't/span'            => 'timeline#span_union_select',   as: :timeline_span_union_select
  post   't/span'            => 'timeline#span_union_redirect'
  get    't/span/:from-:to/g/:name' => 'timeline#span_guild',   as: :timeline_span_guild
  get    't/span/:from-:to/u/:code' => 'timeline#span_union',   as: :timeline_span_union

  get  'r'                    => 'result#index',   as: :result
  get  'r/rulers/:fort'       => 'result#rulers',  as: :result_rulers
  get  'r/date'               => 'result#dates',   as: :result_dates
  get  'r/date/:date/forts'   => 'result#forts',   as: :result_forts
  get  'r/date/:date/callers' => 'result#callers', as: :result_callers
  get  'r/total'              => 'result#total_select',   as: :result_total
  post 'r/total'              => 'result#total_redirect'
  get  'r/total/rank'         => 'result#total_rank',     as: :result_total_rank
  get  'r/total/g/:name'      => 'result#total_guild',    as: :result_total_guild
  get  'r/total/u/:code'      => 'result#total_union',    as: :result_total_union
  get  'r/recently'              => 'result#recently_select',   as: :result_recently
  post 'r/recently'              => 'result#recently_redirect'
  get  'r/recently/:num/rank'    => 'result#recently_rank',     as: :result_recently_rank
  get  'r/recently/:num/g/:name' => 'result#recently_guild',    as: :result_recently_guild
  get  'r/recently/:num/u/:code' => 'result#recently_union',    as: :result_recently_union
  get  'r/span'                   => 'result#span_select',   as: :result_span
  post 'r/span'                   => 'result#span_redirect'
  get  'r/span/:from-:to/rank'    => 'result#span_rank',     as: :result_span_rank
  get  'r/span/:from-:to/g/:name' => 'result#span_guild',    as: :result_span_guild
  get  'r/span/:from-:to/u/:code' => 'result#span_union',    as: :result_span_union

  get    'a'              => 'admin#index',           as: :admin
  get    'a/login'        => 'admin#login',           as: :admin_login
  post   'a/login'        => 'admin#add_session'
  get    'a/backup'       => 'admin#backup',          as: :admin_backup
  post   'a/backup'       => 'admin#backup_execute'
  get    'a/backup/:rev'  => 'admin#backup_download', as: :admin_backup_file
  delete 'a/backup/:rev'  => 'admin#backup_delete'
  get    'a/result'       => 'admin#result',          as: :admin_result
  post   'a/result'       => 'admin#add_result'
  get    'a/rulers'       => 'admin#rulers',          as: :admin_rulers
  post   'a/rulers'       => 'admin#rulers_new'
  get    'a/rulers/:date' => 'admin#rulers_show',     as: :admin_rulers_data
  put    'a/rulers/:date' => 'admin#rulers_update'
  delete 'a/rulers/:date' => 'admin#rulers_delete'

  unless Rails.application.config.consider_all_requests_local
    match '*not_found' => 'root#not_found', via: [:get, :post, :put, :delete, :patch]
  end

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

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
