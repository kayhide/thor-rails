require 'bundler'
require 'thor/group'
require 'rails/generators'

module Rails
  class Ubermensch < Thor::Group
    include Thor::Actions
    include ::Rails::Generators::Actions

    def self.source_root
      File.expand_path('../templates', __FILE__)
    end

    class_option :app_name

    desc 'Install ubermensch files and settings'

    def app_name
      @app_name = options[:app_name] || File.basename(Dir.pwd)
    end

    def create_user
      unless File.exist? 'app/models/user.rb'
        args = %w(
          user provider:string uid:string raw:json
          --no-fixture --no-fixture-replacement
        )
        generate(:model, *args)
      end
    end

    def update_user
      inject_into_file 'app/models/user.rb', <<EOS, after: /\bclass\s*User.*\n/
  include Ubermenschable

  store_accessor :raw, :email, :role, :name, :letter, :color

  delegate :member?, :admin?, to: :role

  def role
    super.try :inquiry
  end

  def to_s
    name || email
  end
EOS
    end

    def update_gems
      gems = Bundler.load.gems.map(&:name)
      required_gems = [
        ['dotenv-rails', { group: 'development' }],
        ['omniauth'],
        ['omniauth-oauth2', '~> 1.3.1']
      ]
      required_gems.reject { |g| gems.include? g.first}.each do |gem_args|
        gem *gem_args
      end
    end

    def update_routes
      route "get '/auth/:provider/callback' => 'session#create'"
      route "get '/auth/failure'            => 'session#create'"
      route "get '/session/'                => 'session#index',   as: :login"
      route "delete '/session/logout'       => 'session#destroy', as: :logout"
    end

    def update_dotenv_sample
      text = <<EOS
export UBERMENSCH_APP_URL='http://ubermensch.dev/'
export UBERMENSCH_APP_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export UBERMENSCH_APP_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

EOS
      if File.exist? '.env.sample'
        prepend_to_file '.env.sample', text
      else
        create_file '.env.sample', text
      end
    end

    def update_application_controller
      inside 'app/controllers' do
        inject_into_file 'application_controller.rb', <<EOS, after: /class.*\n/
  include UbermenschLogin
EOS
      end
    end

    def copy_templates
      directory 'app'
      directory 'config'
      directory 'spec'
      directory 'lib'
    end
  end
end
