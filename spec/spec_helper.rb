require 'rubygems'
require 'spec'
require 'merb-core'

$:.push File.join(File.dirname(__FILE__), '..', 'lib')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end

Merb.start :environment => 'test', :init_file => File.join(File.dirname(__FILE__), 'config', 'init.rb')

use_orm (ENV['ORM'] || :datamapper).to_sym

require 'merb_resourceful'
require 'ruby-debug'

