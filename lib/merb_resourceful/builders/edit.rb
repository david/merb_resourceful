module Merb
  module Plugins
    module Resourceful
      module Builders
        module Edit
          def edit(options = {})
            def_source(options, :edit)

            @controller_class.class_eval do
              def edit
                only_provides :html
                r = resource_get(resource_source_for_edit, params[:id]) or raise ::Merb::Controller::NotFound
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
