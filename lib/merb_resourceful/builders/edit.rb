module Merb
  module Plugins
    module Resourceful
      module Builders
        module Edit
          def edit(options = {})
            get_source_name = build_get_source_method(parent(options), :edit, as(options))
            @controller_class.class_eval <<-EOF
            def edit
              only_provides :html
              @#{@resource_name} = resource_get(#{get_source_name}, params[:id]) or raise NotFound
              display @#{@resource_name}, #{display_options(options[:success]).inspect}
            end
            EOF
          end
        end
      end
    end
  end
end
