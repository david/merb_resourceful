if Merb.orm == :datamapper
  module Merb
    module Plugins
      module Resourceful
        module ORMS
          module DataMapperResource
            def resource_list(source)
              resources_set(source.all)
            end

            def resource_initialize(source, attrs = {})
              resource_set(source.new(attrs))
            end
            
            def resource_get(source, id)
              resource_set(source.get(id))
            end
          end
        end
        
        module Controller
          include ::Merb::Plugins::Resourceful::ORMS::DataMapperResource
        end
      end
    end
  end
end
