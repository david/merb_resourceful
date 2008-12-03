module Merb
  module Plugins
    module Resourceful
      module Builders
        module Show
          def show(options = {})
            get_source_name = build_get_source_method(parent(options), :show, as(options))
            @controller_class.class_eval <<-EOF
              def show
                @#{@resource_name} = resource_get(#{get_source_name}, params[:id]) or raise NotFound
                display @#{@resource_name}, #{display_options(options).inspect}
              end
            EOF
          end
        end
      end
    end
  end
end
