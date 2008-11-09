require 'english/style_orm'

if defined?(Merb)
  module Merb
    module Plugins
      module Resourceful
        module ClassMethods
          def belongs_to(parent, association_name = self.name.demodulize.underscore, options = {})
            resources = self.name.demodulize.underscore
            resource = resources.singularize
            
            options[:actions] ||= [ :index, :show, :new, :edit, :create, :update, :destroy ]
            
            if options[:actions].include?(:index)
              class_eval <<-EOF
                def index
                  display(@#{resources} = resource_list)
                end
              EOF
            end

            if options[:actions].include?(:show)
              class_eval <<-EOF
                def show(id)
                  @#{resource} = get_resource(id) or raise NotFound
                  display @#{resource}
                end
              EOF
            end

            if options[:actions].include?(:new)
              class_eval <<-EOF
                def new
                  only_provides :html
                  @#{resource} = new_resource
                  display @#{resource}
                end
              EOF
            end

            if options[:actions].include?(:edit)
              class_eval <<-EOF
                def edit(id)
                  only_provides :html
                  @#{resource} = get_resource(id) or raise NotFound
                  display @#{resource}
                end
              EOF
            end

            if options[:actions].include?(:create)
              class_eval <<-EOF
                def create(#{resource})
                  @#{resource} = new_resource(#{resource})
                  if @#{resource}.save
                    resource_created(@#{resource})
                  else
                    message[:error] = "#{resource.humanize} failed to be created"
                    render :new
                  end
                end
              
                protected

                def resource_created(resrc)
                  redirect resource_created_route(resrc), :message => { :notice => resource_created_message(resrc) }
                end

                def resource_created_route(resrc)
                  resource(get_parent, :#{resources})
                end

                def resource_created_message(resrc)
                  "#{resource.humanize} created successfully."
                end
              EOF
            end

            if options[:actions].include?(:update)
              class_eval <<-EOF
                def update(id, #{resource})
                  @#{resource} = get_resource(id) or raise NotFound
                  if @#{resource}.update_attributes(#{resource})
                    resource_updated(@#{resource})
                  else
                    display @issue, :edit
                  end
                end
              
                protected

                def resource_updated(resrc)
                  redirect resource_updated_route(resrc), :message => {:notice => resource_updated_message(resrc)}
                end

                def resource_updated_route(resrc)
                  resource(get_parent, :#{resources})
                end

                def resource_updated_message(resrc)
                  "#{resource.humanize} updated successfully."
                end
              EOF
            end
            
            class_eval <<-EOF
              def resource_list
                get_parent.#{association_name}
              end

              def new_resource(params = {})
                get_parent.#{association_name}.build(params)
              end

              def get_resource(id)
                get_parent.#{association_name}.get(id)
              end

              def get_parent
                @#{parent} ||= #{parent.to_s.classify}.get(params[:#{parent}_id])
              end
            EOF
          end
        end
      end
    end
      
    class Controller
      include ::Merb::Plugins::Resourceful
      extend ::Merb::Plugins::Resourceful::ClassMethods
    end
  end
end
