require 'english/style_orm'
require File.join(File.dirname(__FILE__), 'merb_resourceful/builder')
require File.join(File.dirname(__FILE__), 'merb_resourceful/orms/datamapper_resource')

if defined?(Merb)
  module Merb
    module Plugins
      module Resourceful
        module ClassMethods
          def resourceful(options = {}, &block)
            ::Merb::Plugins::Resourceful::Builder.new(self, options).build(&block)
          end
        end # ClassMethods
      end # Resourceful
    end # Plugins
      
    class Controller
      extend ::Merb::Plugins::Resourceful::ClassMethods
    end
  end
end
