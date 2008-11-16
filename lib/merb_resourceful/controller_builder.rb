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
          @parent           = @options[:parent]
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
          
          if block_given? then instance_eval(&block) end
        end
        
        def index(options = {})
          get_source_name = build_get_source_method(options[:parent] || @parent, :index)
          @controller_class.class_eval <<-EOF
            def index
              display(@#{@resource_plural} = resource_list(#{get_source_name}))
            end
          EOF
        end

        def show(options = {})
          get_source_name = build_get_source_method(options[:parent] || @parent, :show)
          @controller_class.class_eval <<-EOF
            def show(id)
              @#{@resource_name} = resource_get(#{get_source_name}, id) or raise NotFound
              display @#{@resource_name}
            end
          EOF
        end

        def new(options = {})
          get_source_name = build_get_source_method(options[:parent] || @parent, :new)
          build_method = if options[:parent] then 'resource_build' else 'resource_new' end
          @controller_class.class_eval <<-EOF
            def new
              only_provides :html
              @#{@resource_name} = #{build_method}(#{get_source_name})
              display @#{@resource_name}
            end
          EOF
        end

        def create(options = {})
          get_source_name = build_get_source_method(options[:parent] || @parent, :create)
          @controller_class.class_eval <<-EOF
            def create(#{@resource_name})
              @#{@resource_name} = resource_new(#{get_source_name}, #{@resource_name})
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
          get_source_name = build_get_source_method(options[:parent] || @parent, :edit)
          @controller_class.class_eval <<-EOF
            def edit(id)
              only_provides :html
              @#{@resource_name} = resource_get(#{get_source_name}, id) or raise NotFound
              display @#{@resource_name}
            end
          EOF
        end

        def update(options = {})
          get_source_name = build_get_source_method(options[:parent] || @parent, :update)
          @controller_class.class_eval <<-EOF
            def update(id, #{@resource_name})
              @#{@resource_name} = resource_get(#{get_source_name}, id) or raise NotFound
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

        def build_get_source_method(parent, for_method)
          method_name = "get_source_for_#{for_method}"
          
          case parent
          when Proc
            association = @resource_plural
            @controller_class.class_eval do
              define_method method_name do 
                (@source ||= instance_eval(&parent)).send(association)
              end
            end
          else
            @controller_class.class_eval <<-EOF
              def #{method_name}
                #{@resource_name.classify}
              end
            EOF
          end
            
          method_name
        end
      end
    end
  end
end
