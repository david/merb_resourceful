module Merb
  module Plugins
    module Resourceful
      module Builders
        module Index
          def index(options = {})
            get_source_name = build_get_source_method(parent(options), :index, as(options))
            
            filter = if options[:filter] then ".#{options[:filter]}" else "" end
            
            @controller_class.class_eval <<-EOF
              def index
                @#{@resource_plural} = resource_list(#{get_source_name})#{filter}
                display @#{@resource_plural}, #{display_options(options).inspect}
              end
            EOF
          end
        end
      end
    end
  end
end
