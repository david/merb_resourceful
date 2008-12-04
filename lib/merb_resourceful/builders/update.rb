module Merb
  module Plugins
    module Resourceful
      module Builders
        module Update
          def update(options = {})
            @controller_class.class_eval do
              def update
                r = resource_get(params[:id]) or raise NotFound
                if r.update(params[self.class::RESOURCE_NAME])
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
              
              def resource_updated_route(resrc)
                resource(resrc)
              end
              
              def resource_updated_message(resrc)
                "#{self.class::RESOURCE_NAME.humanize} updated successfully."
              end
            end
          end
        end
      end
    end
  end
end
