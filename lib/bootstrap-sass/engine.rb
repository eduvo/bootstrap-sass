module Bootstrap
  module Rails
    class Engine < ::Rails::Engine
      initializer "bootstrap-sass.assets.precompile" do |app|
        app.config.assets.precompile << %r(bootstrap/glyphicons-halflings-regular\.(?:eot|svg|ttf|woff)$)
      end
      initializer 'bootstrap-sass.compass_config' do |app|
        # config = Compass::Configuration::Data.new("bootstrap-sass")
        # config.images_path = Engine.root.join('vendor', 'assets', 'images').to_s
        # config.sprite_load_path << Engine.root.join('vendor', 'assets', 'images').to_s
        # config.relative_assets = true
        # Compass.add_configuration(config)
      end
    end
  end
end
