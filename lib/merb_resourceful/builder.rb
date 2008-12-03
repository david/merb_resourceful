require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'index'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'show'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'new'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'create'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'edit'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'update'))
require File.expand_path(File.join(File.dirname(__FILE__), 'builders', 'destroy'))

require File.expand_path(File.join(File.dirname(__FILE__), 'orms', 'datamapper_resource'))

module Merb
  module Plugins
    module Resourceful
      class Builder
        ALL_ACTIONS = %w(index show new create edit update destroy)
        
        def initialize(controller_class, options) 
          @controller_class = controller_class
          @options          = options
          @resource_plural  = @controller_class.name.demodulize.underscore
          @resource_name    = @resource_plural.singularize
        end
        
        def build(&block)
          if Merb.orm == :datamapper
            @controller_class.send :include, ::Merb::Plugins::Resourceful::ORMS::DataMapperResource
          end
          
          ALL_ACTIONS.each { |action| send(action) }
          
          if block_given? then instance_eval(&block) end
        end
        
        include ::Merb::Plugins::Resourceful::Builders::Index
        include ::Merb::Plugins::Resourceful::Builders::Show
        include ::Merb::Plugins::Resourceful::Builders::New
        include ::Merb::Plugins::Resourceful::Builders::Create
        include ::Merb::Plugins::Resourceful::Builders::Edit
        include ::Merb::Plugins::Resourceful::Builders::Update
        include ::Merb::Plugins::Resourceful::Builders::Destroy
        
        protected
        
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
