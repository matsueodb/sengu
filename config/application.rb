require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Sengu
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config',  'locales',  '**',  '*.{rb,yml}').to_s]

    config.active_record.timestamped_migrations = false

    I18n.available_locales = [:en, :ja]
    I18n.enforce_available_locales = true
    I18n.default_locale = :ja

    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # エンジンの読み込み順を設定する
    config.railties_order = [Vdb::Engine, :main_app,  :all]

    #
    # RailsEngineで用意した設定ファイルを読み込む
    #
    initializer :load_rails_config_settings_in_engines, after: :load_rails_config_settings, group: :all do
      rails_config_const = Kernel.const_get(RailsConfig.const_name)
      Rails::Engine::Railties.engines.each do |e|
        rails_config_const.add_source!(e.root.join("config", "settings", "#{Rails.env}.yml").to_s)
        rails_config_const.add_source!(Rails.root.join("settings.#{e.engine_name}.yml").to_s)
      end
      rails_config_const.reload!
    end
  end
end
