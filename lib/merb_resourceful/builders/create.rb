module Merb
  module Plugins
    module Resourceful
      module Builders
        module Create
          def create(options = {})
            get_source_name = build_get_source_method(parent(options), :create, as(options))
            
            route = ""
            if is_children?(options) then route << "@#{as(options)}," end
            route << if options[:to] then options[:to].inspect else "resrc" end
            
            if options[:params]
              @controller_class.send :define_method, :create_resource_params do 
                instance_eval &options[:params]
              end
            else
              @controller_class.class_eval do
                def create_resource_params
                  {}
                end
              end
            end
            
            @controller_class.class_eval <<-EOF
              def create
                @#{@resource_name} = resource_new(#{get_source_name}, 
                                                  params[:#{@resource_name}].merge!(create_resource_params))
                if resource_create(@#{@resource_name})
                  resource_created(@#{@resource_name})
                else
                  message[:error] = "#{@resource_name.humanize} failed to be created"
                  render :new, #{display_options(options[:error]).inspect}
                end
              end

              protected

              def resource_created(resrc)
                redirect resource_created_route(resrc), :message => { :notice => resource_created_message(resrc) }
              end

              def resource_created_route(resrc)
                resource(#{route})
              end
      
              def resource_created_message(resrc)
                "#{@resource_name.humanize} created successfully."
              end
            EOF
      
            if options[:before]
              @controller_class.class_eval do
                private
               
                define_method :before_resource_create, &options[:before]
              end
        
              @controller_class.class_eval <<-EOF
                private

                def resource_create(resrc)
                  before_resource_create(resrc)
                  resrc.save
                end
              EOF
            else
              @controller_class.class_eval <<-EOF2
                def resource_create(resrc)
                  resrc.save
                end
              EOF2
            end
          end
        end
      end
    end
  end
end
