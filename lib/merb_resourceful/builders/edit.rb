module Merb
  module Plugins
    module Resourceful
      module Builders
        module Edit
          def edit(options = {})
            @controller_class.class_eval do
              def edit
                only_provides :html
                r = resource_get(params[:id]) or raise NotFound
                display r, display_options_for_edit
              end
              
              protected
              
              def display_options_for_edit
                {}
              end
            end
          end
        end
      end
    end
  end
end
