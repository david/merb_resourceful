require 'english/style_orm'
require File.join(File.dirname(__FILE__), 'merb_resourceful/controller_builder')
require File.join(File.dirname(__FILE__), 'merb_resourceful/datamapper_builder')

if defined?(Merb)
  module Merb
    module Plugins
      module Resourceful
        module ClassMethods
          def resourceful(options = {}, &block)
            builder = ::Merb::Plugins::Resourceful::ControllerBuilder.new(self, options)
            
            builder.build(&block)
          end
        end # ClassMethods
      end # Resourceful
    end # Plugins
      
    class Controller
      include ::Merb::Plugins::Resourceful
      extend  ::Merb::Plugins::Resourceful::ClassMethods
    end
  end
end
