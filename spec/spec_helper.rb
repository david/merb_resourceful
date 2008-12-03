require 'rubygems'
require 'spec'
require 'merb-core'

$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'merb_resourceful'

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end

Merb.start :environment => 'test', :init_file => File.join(File.dirname(__FILE__), 'config', 'init.rb')
