module Merb
  module Plugins
    module Resourceful
      module Builders
        module Show
          def show(options = {})
            def_source(options, :show)
            
            @controller_class.class_eval do
              def show
                r = resource_get_for_show(params[:id]) or raise Merb::Controller::NotFound
                display r, display_options_for_show
              end
              
              protected
              
              def resource_get_for_show(id)
                resource_get(resource_source_for_show, id)
              end
              
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
