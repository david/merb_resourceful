require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'index'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'show'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'new'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'create'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'edit'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'update'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'destroy'))
require File.expand_path(File.join(File.dirname(__FILE__), 'controller'))


module Merb
  module Plugins
    module Resourceful
      class Builder
        include Builders::Index
        include Builders::Show
        include Builders::New
        include Builders::Create
        include Builders::Edit
        include Builders::Update
        include Builders::Destroy
        
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
          
          ALL_ACTIONS.each { |action| send(action) }
          
          set_source

          @controller_class.class_eval <<-EOF
            def resources_set(r)
              @#{@resource_plural} = r
            end
            
            def resource_set(r)
              @#{@resource_name} = r
            end
          EOF
          if block_given? then instance_eval(&block) end
        end
        
        def has_parent?(options)
          !! (options[:belongs_to] || @options[:belongs_to])
        end
        
        protected
        
        def set_source
          case @options[:belongs_to]
          when Symbol
            @controller_class.class_eval <<-EOF
              def resource_source
                #{@options[:belongs_to]}.#{@resource_plural}
              end
              
              def resource_parent_get 
                #{@options[:belongs_to]}
              end
            EOF
          else
            @controller_class.class_eval <<-EOF
              def resource_source
                #{@resource_class}
              end
            EOF
          end
        end              
        
        def is_children?(options)
          !! (options[:belongs_to] || @options[:belongs_to])
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
