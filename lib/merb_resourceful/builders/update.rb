module Merb
  module Plugins
    module Resourceful
      module Builders
        module Update
          def update(options = {})
            get_source_name = build_get_source_method(parent(options), :update, as(options))
            
            route = ""
            if is_children?(options) then route << "@#{as(options)}," end
            route << if options[:to] then options[:to].inspect else "resrc" end
            
            @controller_class.class_eval <<-EOF
              def update
                @#{@resource_name} = resource_get(#{get_source_name}, params[:id]) or raise NotFound
                if @#{@resource_name}.update_attributes(params[:#{@resource_name}])
                  resource_updated(@#{@resource_name})
                else
                  message[:error] = "#{@resource_name.humanize} failed to be updated"
                  render :edit
                end
              end

              protected

              def resource_updated(resrc)
                redirect resource_updated_route(resrc), :message => {:notice => resource_updated_message(resrc)}
              end

              def resource_updated_route(resrc)
                resource(#{route})
              end

              def resource_updated_message(resrc)
                "#{@resource_name.humanize} updated successfully."
              end
            EOF
          end
        end
      end
    end
  end
end
