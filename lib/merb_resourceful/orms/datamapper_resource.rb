module Merb
  module Plugins
    module Resourceful
      module ORMS
        module DataMapperResource
          def resource_list(source)
            source.all
          end

          def resource_new(source, attrs = {})
            source.new(attrs)
          end
          
          def resource_get(source, id)
            source.get(id)
          end
        end
      end
    end
  end
end
