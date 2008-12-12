require File.expand_path(File.join(File.dirname(__FILE__), 'controller'))


module Merb
  module Plugins
    module Resourceful
      class Builder
        ALL_ACTIONS = %w(index show new create edit update destroy)
        
        def initialize(controller_class, options) 
          @controller_class = controller_class
          @options          = options
          @resource_class   = @controller_class.name.demodulize.singularize
          @resource_plural  = @controller_class.name.demodulize.underscore
          @resource_name    = @resource_plural.singularize
          
        end
        
        def build(&block)
          @controller_class.send :include, ::Merb::Plugins::Resourceful::Controller
          @controller_class.const_set('RESOURCE_NAME', @resource_name)
          @controller_class.const_set('RESOURCES_NAME', @resource_plural)
          
          def_source

          ALL_ACTIONS.each { |action| send(action) }
          
          @controller_class.class_eval <<-EOF
            def resources_set(r)
              @#{@resource_plural} = r
            end
            
            def resource_set(r)
              @#{@resource_name} = r
            end
            
            def resource_ivar
              @#{@resource_name}
            end
          EOF
            
          if block_given? then instance_eval(&block) end
        end
          
        def index(options = {})
          def_source(options, :index)

          filter = options[:filter] && ".#{options[:filter]}"
          params = options[:params] && "(resource_params_for_index)"
          @controller_class.class_eval <<-EOF
            def resource_index
              resources_set(resource_list(resource_source_for_index)#{filter}#{params})
            end
          EOF

          @controller_class.class_eval do
            def index
              display resource_index, render_options_for_index
            end
          end
          
          inject_render_options(options, :index)
          inject_params(options, :index)
        end
        
        def show(options = {})
          def_source(options, :show)

          @controller_class.class_eval do
            def show
              r = resource_get_for_show(params[:id]) or raise Merb::Controller::NotFound
              display r, render_options_for_show
            end

            protected

            def resource_get_for_show(id)
              resource_get(resource_source_for_show, id)
            end
          end

          inject_render_options(options, :show)
        end
        
        def new(options = {})
          def_source(options, :new)

          @controller_class.class_eval do
            def new
              only_provides :html
              display resource_new, render_options_for_new
            end

            protected

            def resource_new
              resource_initialize(resource_source_for_new)
            end
          end
          
          inject_render_options(options, :new)
        end
        
        def create(options = {})
          def_source(options, :create)

          @controller_class.class_eval do
            def create
              r = resource_initialize(resource_source_for_create, 
                                      params[self.class::RESOURCE_NAME].merge!(resource_params_for_create))
              if r.save
                resource_created(r)
              else
                message[:error] = "#{self.class::RESOURCE_NAME.humanize} failed to be created"
                render :new, render_options_for_create
              end
            end

            protected

            def resource_created(resrc)
              redirect resource_created_route, :message => { :notice => resource_created_message(resrc) }
            end

            def resource_created_message(resrc)
              "#{self.class::RESOURCE_NAME.singularize} created successfully."
            end
          end

          inject_route(options, :create)
          inject_params(options, :create)
          inject_render_options(options, :create)
        end
        
        def edit(options = {})
          def_source(options, :edit)

          @controller_class.class_eval do
            def edit
              only_provides :html
              r = resource_get(resource_source_for_edit, params[:id]) or raise ::Merb::Controller::NotFound
              display r, render_options_for_edit
            end
          end
          
          inject_render_options(options, :edit)
        end
        
        def update(options = {})
          def_source(options, :update)

          @controller_class.class_eval do
            def update
              r = resource_get(resource_source_for_update, params[:id]) or raise ::Merb::Controller::NotFound
              if r.update(params[self.class::RESOURCE_NAME].merge!(resource_params_for_update))
                resource_updated(r)
              else
                message[:error] = "#{RESOURCE_NAME.humanize} failed to be updated"
                render :edit, render_options_for_update
              end
            end

            protected

            def resource_updated(resrc)
              redirect resource_updated_route, :message => {:notice => resource_updated_message(resrc)}
            end

            def resource_updated_message(resrc)
              "#{self.class::RESOURCE_NAME.humanize} updated successfully."
            end
          end

          inject_route(options, :update)
          inject_params(options, :update)
          inject_render_options(options, :update)
        end
        
        def destroy
        end
        
        private
        
        def has_parent?(options)
          !! (options[:belongs_to] || @options[:belongs_to])
        end
        
        def inject_route(options, method_name)
          to = (options[:to] && options[:to].inspect) || "resource_ivar"

          if has_parent?(options)
            @controller_class.class_eval <<-EOF
              protected
              def resource_#{method_name}d_route
                resource(resource_parent_get_for_#{method_name}, #{to})
              end
            EOF
          else
            @controller_class.class_eval <<-EOF
              protected
              def resource_#{method_name}d_route
                resource(#{to})
              end
            EOF
          end
        end
        
        def inject_render_options(options, method_name)
          if options[:layout]
            @controller_class.class_eval do 
              protected
              define_method "render_options_for_#{method_name}" do
                { :layout => options[:layout] }
              end
            end
          else
            @controller_class.class_eval <<-EOF
              protected
              def render_options_for_#{method_name}() {} end
            EOF
          end
        end
        
        def inject_params(options, method_name)
          case options[:params]
          when Proc
            @controller_class.class_eval do
              protected
              define_method "resource_params_for_#{method_name}", &options[:params]
            end
          else
            @controller_class.class_eval <<-EOF
              protected
              def resource_params_for_#{method_name}() {} end
            EOF
          end
        end
        
        def def_source(options = {}, method_name = nil)
          source = options[:belongs_to] || options[:scope] || @options[:belongs_to] || @options[:scope]
          
          case source
          when Symbol
            def_source_with_scope(source, method_name)
          else
            if method_name.nil?
              @controller_class.class_eval <<-EOF
                protected
                def resource_source
                  #{@resource_class}
                end
              EOF
            else
              @controller_class.class_eval do
                alias_method "resource_source_for_#{method_name}", :resource_source
              end
            end
          end
        end
        
        def def_source_with_scope(source, method_name = nil)
          suffix = method_name && "_for_#{method_name}"
          
          s = <<-EOF
            protected
            def resource_source#{suffix}
              #{source}.#{@resource_plural}
            end

            def resource_parent_get#{suffix}
              #{source}
            end
          EOF

          @controller_class.class_eval s
        end
      end
    end
  end
end
