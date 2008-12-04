module Merb
  module Plugins
    module Resourceful
      module Builders
        module Create
          def create(options = {})
            builder = self

            @controller_class.class_eval do
              def create
                r = resource_new(params[self.class::RESOURCE_NAME].merge!(create_resource_params))
                if r.save
                  resource_created(r)
                else
                  message[:error] = "#{self.class::RESOURCE_NAME.humanize} failed to be created"
                  render :new, layout_options_for_new
                end
              end
              
              protected
              
              def resource_created(resrc)
                redirect resource_created_route(resrc), :message => { :notice => resource_created_message(resrc) }
              end

              if builder.has_parent?(options)
                def resource_created_route(resrc)
                  resource(resource_parent_get, resrc)
                end
              else
                def resource_created_route(resrc)
                  resource(resrc)
                end
              end
              
              def resource_created_message(resrc)
                "#{self.class::RESOURCE_NAME.singularize} created successfully."
              end
              
              def create_resource_params
                {}
              end
            end
          end
        end
      end
    end
  end
end
