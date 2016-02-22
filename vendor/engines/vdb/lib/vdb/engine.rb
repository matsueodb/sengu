# NOTE: 以下をrequireしないとrspecテストが通らない
require("devise")
require("kaminari")
require("rails_config")

module Vdb
  class Engine < ::Rails::Engine
    isolate_namespace Vdb
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.to_prepare do
      Dir.glob(Vdb::Engine.root + "app/controllers/**/*.rb").each do |c|
        require_dependency(c)
      end

      Dir.glob(Vdb::Engine.root + "app/models/*.rb").each do |c|
        require_dependency(c)
      end

      Dir.glob(Vdb::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end
  end
end
