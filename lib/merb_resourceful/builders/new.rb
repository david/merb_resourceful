module Merb
  module Plugins
    module Resourceful
      module Builders
        module New
          def new(options = {})
            get_source_name = build_get_source_method(parent(options), :new, as(options))
            
            @controller_class.class_eval <<-EOF
              def new
                only_provides :html
                @#{@resource_name} = resource_new(#{get_source_name})
                display @#{@resource_name}, #{display_options(options).inspect}
              end
            EOF
          end
        end
      end
    end
  end
end
