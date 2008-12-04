module Merb
  module Plugins
    module Resourceful
      module Builders
        module New
          def new(options = {})
            @controller_class.class_eval do
              def new
                only_provides :html
                display resource_new, display_options_for_new
              end
              
              protected

              def display_options_for_new
                {}
              end
            end
          end
        end
      end
    end
  end
end
