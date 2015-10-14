require_relative 'error_module'

module KineticCafe # :nodoc:
  # A subclass of StandardError that can render itself as a descriptive JSON
  # hash, or as a hash that can be passed to a Rails controller +render+
  # method.
  #
  # This class is not expected to be used on its own, but is used as the parent
  # (both in terms of base class and namespace) of an application error
  # hierarchy.
  #
  # == Defining an Error Hierarchy
  #
  # An error hierarchy is defined by using KineticCafe::Error.hierarchy and
  # defining error subclasses with the DSL.
  #
  #   KineticCafe::Error.hierarchy(class: :MyErrorBase) do
  #     not_found class: :user # => MyErrorBase::UserNotFound
  #     unauthorized class: :user # => MyErrorBase::UserUnauthorized
  #     forbidden class: :user # => MyErrorBase::UserForbidden
  #     conflict class: :user# => MyErrorBase::UserConflict
  #   end
  #
  # These errors then can be used and caught with a generic KineticCafe::Error
  # rescue clause and handled there, as is shown in the included
  # KineticCafe::ErrorHandler controller concern for Rails.
  class Error < ::StandardError
    VERSION = '1.8' # :nodoc:

    # Get the KineticCafe::Error functionality.
    include KineticCafe::ErrorModule

    # Create an error hierarchy using +options+ and the optional +block+. When
    # given, the +block+ will either +yield+ the hierarchy base (if the block
    # accepts arguments) or run with +instance_eval+.
    #
    # If the class does not already include KineticCafe::ErrorModule, it will
    # be included.
    #
    # === Building a Hierarchy
    #
    # A hierarchy using KineticCafe::Error as its base can be created with
    # KineticCafe::Error.hierarchy and no arguments.
    #
    #   KineticCafe::Error.hierarchy do
    #     not_found class: :user # => KineticCafe::Error::UserNotFound
    #   end
    #
    # A hierarchy in a new error class (that descends from KineticCafe::Error)
    # can be created by providing a class name:
    #
    #   KineticCafe::Error.hierarchy(class: :MyErrorBase) do
    #     not_found class: :user # => MyErrorBase::UserNotFound
    #   end
    #
    # The new error class can itself be in a namespace, but the parent
    # namespace must be identified:
    #
    #   module My; end
    #
    #   KineticCafe::Error.hierarchy(class: :ErrorBase, namespace: My) do
    #     not_found class: :user # => My::ErrorBase::UserNotFound
    #   end
    #
    # It is also possible to use an explicit descendant easily:
    #
    #   module My
    #     ErrorBase = Class.new(KineticCafe::Error)
    #   end
    #
    #   KineticCafe::Error.hierarchy(class: My::ErrorBase) do
    #     not_found class: :user # => My::ErrorBase::UserNotFound
    #   end
    #
    # === Rack::Utils Errors and Helpers
    #
    # By default, when Rack::Utils is present, KineticCafe::Error will present
    # helper methods and default HTTP status code errors.
    #
    #   KineticCafe::Error.hierarchy do
    #     not_found class: :user # => KineticCafe::Error::UserNotFound
    #   end
    #
    #   KineticCafe::Error::UserNotFound.new.status # => :not_found / 404
    #   KineticCafe::Error::NotFound.new.status #  => :not_found
    #
    # These may be controlled with the option +rack_status+. If provided as
    # +false+, neither will be created:
    #
    #   KineticCafe::Error.hierarchy(rack_status: false) do
    #     not_found class: :user # => raises NoMethodError
    #   end
    #
    #   fail KineticCafe::Error::NotFound # => raises NameError
    #
    # These may be controlled individually, as well. Disable the methods:
    #
    #   KineticCafe::Error.hierarchy(rack_status: { methods: false }) do
    #     not_found class: :user # => raises NoMethodError
    #   end
    #
    #   fail KineticCafe::Error::NotFound # => works
    #
    # Disable the default error classes:
    #
    #   KineticCafe::Error.hierarchy(rack_status: { errors: false }) do
    #     not_found class: :user # => KineticCafe::Error::UserNotFound
    #   end
    #
    #   fail KineticCafe::Error::NotFound # => raises NoMethodError
    #
    # === Options
    #
    # +class+:: If given, identifies the base class and host namespace of the
    #           error hierarchy. Provided as a class, that class is used.
    #           Provided as a symbol, creates a new class that descends from
    #           KineticCafe::Error.
    # +namespace+:: If +class+ is provided as a symbol, this namespace will be
    #               the one where the new error class is created.
    # +rack_status+:: Controls the creation of error-definition helper methods
    #                 and errors based on Rack::Utils status codes (e.g.,
    #                 +not_found+). +true+ creates both; +false+ disables both.
    #                 The values <tt>{ methods: false }</tt> and <tt>{ errors:
    #                 false }</tt> individually control one.
    def self.hierarchy(options = {}, &block) # :yields base:
      base = options.fetch(:class, self)

      if base.kind_of?(Symbol)
        ns = options.fetch(:namespace, Object)
        base = if ns.const_defined?(base)
                 ns.const_get(base)
               else
                 ns.const_set(base, Class.new(self))
               end
      end

      if base.singleton_class < KineticCafe::ErrorDSL
        fail "#{base} is already a root hierarchy"
      end

      unless base <= ::StandardError
        fail "#{base} cannot root a hierarchy (not a StandardError)"
      end

      unless base <= KineticCafe::ErrorModule
        base.send(:include, KineticCafe::ErrorModule)
      end

      unless (rs_defined = base.respond_to?(:__rack_status))
        rack_status_default = { errors: true, methods: true }
        base.send :define_singleton_method, :__rack_status do
          options.fetch(:rack_status, rack_status_default)
        end
      end

      base.send(:extend, KineticCafe::ErrorDSL)

      if block_given?
        if block.arity > 0
          yield base
        else
          base.instance_eval(&block)
        end
      end

      base
    ensure
      if base.respond_to?(:__rack_status) && !rs_defined
        base.singleton_class.send :undef_method, :__rack_status
      end
    end

    private

    def default_status
      defined?(Rack::Utils) && :bad_request || 400
    end

    def stringify(object, namespace = nil)
      case object
      when Hash
        stringify_hash(object, namespace).compact.sort.join('; ')
      when Array
        stringify_array(object, namespace)
      else
        stringify_value(namespace, object)
      end
    end

    def stringify_hash(hash, namespace)
      hash.collect do |key, value|
        key = namespace ? "#{namespace}[#{key}]" : key
        case value
        when Hash
          next if value.nil?
          stringify(value, key)
        when Array
          stringify_array(key, value)
        else
          stringify_value(key, value)
        end
      end
    end

    def stringify_array(key, array)
      key = "#{key}[]"
      if array.empty?
        stringify_value(key, [])
      else
        array.collect { |value| stringify(value, key) }.join(', ')
      end
    end

    def stringify_value(key, value)
      "#{key}: #{value}"
    end
  end
end

require_relative 'error_dsl'
require_relative 'error_engine' if defined?(::Rails)
require_relative 'error_tasks' if defined?(::Rake::DSL)
