module Merb
  module Plugins
    module Resourceful
      module Builders
        module Show
          def show(options = {})
            @controller_class.class_eval do
              def show
                r = resource_get(params[:id]) or raise NotFound
                display r, display_options_for_show
              end
              
              protected
              
              def display_options_for_show
                {}
              end
            end
          end
        end
      end
    end
  end
end
