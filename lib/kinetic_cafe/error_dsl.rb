# frozen_string_literal: true

##
module KineticCafe
  # Make defining new children of KineticCafe::Error easy. Adds the
  # #define_error method and #severity block modifier.
  #
  # If using when Rack is present, useful variant methodss are provided
  # matching Rack status symbol codes. These set the default status to the Rack
  # status.
  #
  #    conflict class: :user # => UserConflict, status: :conflict
  #    not_found class: :post # => PostNotFound, status: :not_found
  module ErrorDSL
    # Convert ThisName to this_name. Uses #underscore if +name+ responds to it.
    # Otherwise, it uses a super naïve version.
    def self.underscore(name)
      name = name.to_s
      if name.respond_to?(:underscore)
        name.underscore.freeze
      else
        name.dup.tap { |n|
          n.gsub!(/[[:upper:]]/) do "_#{$&}".downcase end
          n.sub!(/^_/, '')
        }.freeze
      end
    end

    # Demodulizes This::Name to just Name. Uses name#demodulize if it is
    # available, or a naïve version otherwise.
    def self.demodulize(name)
      name = name.to_s
      if name.respond_to?(:demodulize)
        name.demodulize.freeze
      else
        name.split(/::/)[-1].freeze
      end
    end

    # Demodulizes and underscores the provided name.
    def self.namify(name)
      underscore(demodulize(name.to_s))
    end

    # Convert this_name to ThisName. Uses #camelize if +name+ responds to it,
    # or a naïve version otherwise.
    def self.camelize(name)
      name = name.to_s
      if name.respond_to?(:camelize)
        name.camelize.freeze
      else
        "_#{name}".gsub(/_([a-z])/i) { Regexp.last_match(1).upcase }.freeze
      end
    end

    # Define a new error as a subclass of the exception hosting ErrorDSL.
    # Options is a Hash supporting the following values:
    #
    # +status+::   A number or Ruby symbol representing the HTTP status code
    #              associated with this error. If not provided, defaults to
    #              :bad_request. Must be provided if +class+ is provided. HTTP
    #              status codes are defined in Rack::Utils.
    # +severity+:: A Ruby symbol representing the severity level associated
    #              with this error. If not provided, defaults to :error. Error
    #              severity levels are defined in Logger::Severity.
    # +key+::      The name of the error class to be created. Provide as a
    #              snake_case value that will be turned into a camelized class
    #              name. Mutually exclusive with +class+.
    # +class+::    The name of the class the error is for. If present, +status+
    #              must be provided to create a complete error class. That is,
    #
    #                define_error class: :object, status: :not_found
    #
    #              will create an +ObjectNotFound+ error class.
    # +header+::   Indicates that when this is caught, it should not be
    #              returned with full details, but should instead be treated as
    #              a header-only API response. Also available as +header_only+.
    # +internal+:: Generates a response that indicates to clients that the
    #              error should not be shown to users.
    # +i18n_params+:: An array of parameter names that are expected to be
    #                 provided for translation. This helps document the
    #                 expected translations.
    #
    # If a +block+ is provided, errors may be defined as subclasses of the error
    # defined here.
    def define_error(options, &block)
      fail ArgumentError, 'invalid options' unless options.kind_of?(Hash)
      fail ArgumentError, 'define what error?' if options.empty?

      options = options.dup
      status = options[:status]
      severity = options[:severity]

      klass = options.delete(:class)
      if klass
        fail ArgumentError, ":key conflicts with class:#{klass}" if options.key?(:key)

        key = if status.kind_of?(Symbol) || status.kind_of?(String)
          "#{klass}_#{KineticCafe::ErrorDSL.namify(status)}"
        else
          "#{klass}_#{KineticCafe::ErrorDSL.namify(name)}"
        end

        key = String.new(key)
      else
        key = options.fetch(:key) {
          fail ArgumentError, 'one of :key or :class must be provided'
        }.to_s
      end

      key.tap do |k|
        k.gsub!(/[^[:word:]]/, '_')
        k.squeeze!('_')
        k.gsub!(/^_+/, '')
        k.gsub!(/_+$/, '')
        k.freeze
      end

      error_name = KineticCafe::ErrorDSL.camelize(key)
      i18n_key_base = respond_to?(:i18n_key_base) && self.i18n_key_base ||
        'kcerrors'
      i18n_key = "#{i18n_key_base}.#{key}"

      if const_defined?(error_name)
        message = String.new("key:#{key} already exists as #{error_name}")
        message << " with class:#{klass}" if klass
        fail ArgumentError, message
      end

      error = Class.new(self)
      error.send :define_method, :name, -> { key }
      error.send :define_method, :i18n_key, -> { i18n_key }
      error.send :define_singleton_method, :i18n_key, -> { i18n_key }

      if options[:header] || options[:header_only]
        error.send :define_method, :header?, -> { true }
        error.send :alias_method, :header_only?, :header?
      end

      error.send :define_method, :internal?, -> { true } if options[:internal]

      i18n_params = options[:i18n_params]
      if i18n_params || !error.respond_to?(:i18n_params)
        i18n_params = Array(i18n_params).freeze
        error.send :define_singleton_method, :i18n_params, -> { i18n_params }
      end

      status ||= defined?(Rack::Utils) && :bad_request || 400
      status.freeze

      if status
        error.send :define_method, :default_status, -> { status }
        error.send :private, :default_status
        error.send :define_singleton_method, :default_status, -> { status }
      end

      severity ||= @severity || :error
      severity.freeze

      if severity
        error.send :define_method, :default_severity, -> { severity }
        error.send :define_singleton_method, :default_severity, -> { severity }
      end

      error.instance_exec(&block) if block

      const_set(error_name, error)
    end

    # Temporarily override the default severity with +value+ for errors defined in
    # the provided +block+.
    def severity(value, &block)
      old_severity, @severity = @severity, value
      fail 'Severity must have a block' unless block
      instance_exec(&block)
    ensure
      @severity = old_severity
    end

    # Keep track of subclasses of errors using ErrorDSL.
    def inherited(subclass) #:nodoc:
      super
      KineticCafe::ErrorDSL.inheritors << subclass
    end

    def self.included(_mod) # :nodoc:
      fail "#{self} cannot be included"
    end

    def self.extended(base) # :nodoc:
      unless base < ::StandardError
        fail "#{self} cannot extend #{base} (not a StandardError)"
      end

      inheritors << base

      rack_status = base.__rack_status if base.respond_to?(:__rack_status)

      case rack_status
      when Hash
        rack_status = { methods: true, errors: true }.merge(rack_status)
      when true, nil
        rack_status = {}.freeze
      when false
        rack_status = { methods: false, errors: false }.freeze
      end

      if defined?(Rack::Utils) && rack_status
        Rack::Utils::SYMBOL_TO_STATUS_CODE.each_key do |name|
          # Make the Rack names safe to use
          name = name.to_s.gsub(/[^[:word:]]/, '_').squeeze('_').to_sym
          if rack_status.fetch(:methods, true)
            base.singleton_class.send :define_method, name do |options = {}, &block|
              define_error(options.merge(status: name), &block)
            end
          end

          if rack_status.fetch(:errors, true)
            base.send :define_error, status: name, key: name
          end
        end
      end
    end

    def self.inheritors # :nodoc:
      @inheritors ||= []
    end
  end
end
