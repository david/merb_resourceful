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
            
          ALL_ACTIONS.each { |action| send(action) }
          
          if block_given? then instance_eval(&block) end
        end
        
        def index(options = {})
          get_source_name = build_get_source_method(parent(options), :index, as(options))
          
          filter = if options[:filter] then ".#{options[:filter]}" else "" end
          
          @controller_class.class_eval <<-EOF
            def index
              @#{@resource_plural} = resource_list(#{get_source_name})#{filter}
              display @#{@resource_plural}, #{display_options(options).inspect}
            end
          EOF
        end

        def show(options = {})
          get_source_name = build_get_source_method(parent(options), :show, as(options))
          @controller_class.class_eval <<-EOF
            def show(id)
              @#{@resource_name} = resource_get(#{get_source_name}, id) or raise NotFound
              display @#{@resource_name}, #{display_options(options).inspect}
            end
          EOF
        end

        def new(options = {})
          get_source_name = build_get_source_method(parent(options), :new, as(options))
          build_method = if options[:parent] then 'resource_build' else 'resource_new' end
          @controller_class.class_eval <<-EOF
            def new
              only_provides :html
              @#{@resource_name} = #{build_method}(#{get_source_name})
              display @#{@resource_name}, #{display_options(options).inspect}
            end
          EOF
        end

        def create(options = {})
          get_source_name = build_get_source_method(parent(options), :create, as(options))
          
          route = ""
          if is_children?(options) then route << "@#{as(options)}," end
          route << if options[:to] then options[:to].inspect else "resrc" end
          
          @controller_class.class_eval <<-EOF
            def create(#{@resource_name})
              @#{@resource_name} = resource_new(#{get_source_name}, #{@resource_name})
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

        def edit(options = {})
          get_source_name = build_get_source_method(parent(options), :edit, as(options))
          @controller_class.class_eval <<-EOF
            def edit(id)
              only_provides :html
              @#{@resource_name} = resource_get(#{get_source_name}, id) or raise NotFound
              display @#{@resource_name}, #{display_options(options[:success]).inspect}
            end
          EOF
        end

        def update(options = {})
          get_source_name = build_get_source_method(parent(options), :update, as(options))
          
          route = ""
          if is_children?(options) then route << "@#{as(options)}," end
          route << if options[:to] then options[:to].inspect else "resrc" end
          
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

            def resource_updated_route(resrc)
              resource(#{route})
            end
            
            def resource_updated_message(resrc)
              "#{@resource_name.humanize} updated successfully."
            end
          EOF
        end

        def destroy(options = {})
        end
        
        private
        
        def is_children?(options)
          !! (options[:belongs_to] || @options[:belongs_to])
        end
        
        def parent(options)
          options[:parent] || options[:belongs_to] || @options[:parent] || @options[:belongs_to]
        end
        
        def as(options)
          options[:as] || @options[:as] || :resource_parent
        end
        
        def display_options(options)
          return {} if options.nil?
          
          display_opts = {}
          if options[:layout] then display_opts[:layout] = options[:layout] end
          display_opts
        end

        def build_get_source_method(parent, for_method, as)
          method_name = "get_source_for_#{for_method}"
          
          case parent
          when Proc
            association = @resource_plural
            @controller_class.class_eval do
              define_method method_name do 
                instance_variable_get("@#{as}") || 
                  instance_variable_set("@#{as}", instance_eval(&parent)).send(association)
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
