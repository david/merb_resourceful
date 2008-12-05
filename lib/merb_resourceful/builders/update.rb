module Merb
  module Plugins
    module Resourceful
      module Builders
        module Update
          def update(options = {})
            def_source(options, :update)

            builder = self
            
            @controller_class.class_eval do
              def update
                r = resource_get(resource_source_for_update, params[:id]) or raise ::Merb::Controller::NotFound
                if r.update(params[self.class::RESOURCE_NAME].merge!(resource_params_for_update))
                  resource_updated(r)
                else
                  message[:error] = "#{RESOURCE_NAME.humanize} failed to be updated"
                  render :edit
                end
              end
              
              protected
              
              def resource_updated(resrc)
                redirect resource_updated_route(resrc), :message => {:notice => resource_updated_message(resrc)}
              end
              
              if builder.has_parent?(options)
                def resource_updated_route(resrc)
                  resource(resource_parent_get_for_update, resrc)
                end
              else
                def resource_updated_route(resrc)
                  resource(resrc)
                end
              end
              
              def resource_updated_message(resrc)
                "#{self.class::RESOURCE_NAME.humanize} updated successfully."
              end
              
              def resource_params_for_update
                {}
              end
            end
            
            inject_params(options, :update)
          end
        end
      end
    end
  end
end
