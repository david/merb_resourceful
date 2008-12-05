module Merb
  module Plugins
    module Resourceful
      module Builders
        module Index
          def index(options = {})
            def_source(options, :index)

            filter = options[:filter] && ".#{options[:filter]}"
            @controller_class.class_eval <<-EOF
              def resource_index
                resources_set(resource_list(resource_source_for_index)#{filter})
              end
            EOF

            @controller_class.class_eval do
              def index
                display resource_index, display_options_for_index
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
