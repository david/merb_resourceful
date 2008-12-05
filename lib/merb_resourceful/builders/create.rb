module Merb
  module Plugins
    module Resourceful
      module Builders
        module Create
          def create(options = {})
            def_source(options, :create)
            
            builder = self
            
            @controller_class.class_eval do
              def create
                r = resource_initialize(resource_source_for_create, 
                                        params[self.class::RESOURCE_NAME].merge!(resource_params_for_create))
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
                  resource(resource_parent_get_for_create, resrc)
                end
              else
                def resource_created_route(resrc)
                  resource(resrc)
                end
              end
              
              def resource_created_message(resrc)
                "#{self.class::RESOURCE_NAME.singularize} created successfully."
              end
              
              def resource_params_for_create
                {}
              end
            end
            
            inject_params(options, :create)
          end
        end
      end
    end
  end
end
