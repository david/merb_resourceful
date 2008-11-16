module Merb
  module Plugins
    module Resourceful
      class ControllerBuilder
        ALL_ACTIONS = %w(index show new create edit update destroy)
        
        def initialize(controller_class, options) 
          @controller_class = controller_class
          @options          = options
          @resource_plural  = @controller_class.name.demodulize.underscore
          @resource_name    = @resource_plural.singularize
        end
        
        def build(&block)
          if Merb.orm == :datamapper
            @controller_class.send :include, ::Merb::Plugins::Resourceful::DataMapperBuilder
          end
            
          @controller_class.class_eval do
            def resource_updated_route(rsrc)
            end
            
            def resource_created_route(rsrc)
            end
          end
          
          ALL_ACTIONS.each { |action| send(action) }
          
          setup_source(@options[:parent])
          
          if block_given? then instance_eval(&block) end
        end
        
        def index(options = {})
          @controller_class.class_eval <<-EOF
            def index
              display(@#{@resource_plural} = resource_list(get_source))
            end
          EOF
        end

        def show(options = {})
          @controller_class.class_eval <<-EOF
            def show(id)
              @#{@resource_name} = resource_get(get_source, id) or raise NotFound
              display @#{@resource_name}
            end
          EOF
        end

        def new(options = {})
          @controller_class.class_eval <<-EOF
            def new
              only_provides :html
              @#{@resource_name} = resource_new(get_source)
              display @#{@resource_name}
            end
          EOF
        end

        def create(options = {})
          @controller_class.class_eval <<-EOF
            def create(#{@resource_name})
              @#{@resource_name} = resource_new(get_source, #{@resource_name})
              if @#{@resource_name}.save
                resource_created(@#{@resource_name})
              else
                message[:error] = "#{@resource_name.humanize} failed to be created"
                render :new
              end
            end

            protected

            def resource_created(resrc)
              redirect resource_created_route(resrc), :message => { :notice => resource_created_message(resrc) }
            end

            def resource_created_message(resrc)
              "#{@resource_name.humanize} created successfully."
            end
          EOF
        end

        def edit(options = {})
          @controller_class.class_eval <<-EOF
            def edit(id)
              only_provides :html
              @#{@resource_name} = resource_get(get_source, id) or raise NotFound
              display @#{@resource_name}
            end
          EOF
        end

        def update(options = {})
          @controller_class.class_eval <<-EOF
            def update(id, #{@resource_name})
              @#{@resource_name} = resource_get(get_source, id) or raise NotFound
              if @#{@resource_name}.update_attributes(#{@resource_name})
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

            def resource_updated_message(resrc)
              "#{@resource_name.humanize} updated successfully."
            end
          EOF
        end

        def destroy(options = {})
        end
        
        private

        def setup_source(parent)
          case parent
          when Proc
            association = @resource_plural
            @controller_class.class_eval do
              define_method :get_source do 
                (@source ||= instance_eval(&parent)).send(association)
              end
            end
          else
            @controller_class.class_eval <<-EOF
              def get_source
                #{@resource_name.classify}
              end
            EOF
          end
        end
      end
    end
  end
end
