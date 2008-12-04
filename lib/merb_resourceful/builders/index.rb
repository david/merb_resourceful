module Merb
  module Plugins
    module Resourceful
      module Builders
        module Index
          def index(options = {})
            @controller_class.class_eval do
              def index
                display resource_list, display_options_for_index
              end
              
              protected

              def display_options_for_index
                {}
              end
            end
          end
        end
      end
    end
  end
end
