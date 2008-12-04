if Merb.orm == :datamapper
  module Merb
    module Plugins
      module Resourceful
        module ORMS
          module DataMapperResource
            def resource_list
              resources_set(resource_source.all)
            end

            def resource_new(attrs = {})
              resource_set(resource_source.new(attrs))
            end
            
            def resource_get(id)
              resource_set(resource_source.get(id))
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
