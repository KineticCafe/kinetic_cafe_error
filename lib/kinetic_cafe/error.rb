module KineticCafe #:nodoc:
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
  # An error hierarchy is defined by subclassing KineticCafe::Error, extending
  # it with KineticCafe::ErrorDSL, and defining error subclasses with the DSL.
  #
  #   class MyErrorBase < KineticCafe::Error
  #     extend KineticCafe::ErrorDSL
  #
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
    VERSION = '1.0' # :nodoc:

    # The HTTP status to be returned. If not provided in the constructor, uses
    # #default_status.
    attr_reader :status
    # Extra data relevant to recipients of the exception, provided on
    # construction.
    attr_reader :extra
    # The exception that caused this exception; provided on construction.
    attr_reader :cause

    # Create a new error with the given parameters.
    #
    # === Options
    #
    # +message+:: A message override. This may be provided either as the first
    #             parameter to the constructor or may be provided as an option.
    #             A value provided as the first parameter overrides any other
    #             value.
    # +status+::  An override to the HTTP status code to be returned by this
    #             error by default.
    # +i18n_params+:: The parameters to be sent to I18n.translate with the
    #                 #i18n_key.
    # +cause+:: The exception that caused this error. Used to wrap an earlier
    #           exception.
    # +extra+:: Extra data to be returned in the API representation of this
    #           exception.
    # +query+:: A hash of parameters, typically from Rails controller +params+
    #           or model +where+ query. This hash will be converted into a
    #           string value similar to ActiveSupport#to_query.
    #
    # Any unmatched options will be added transparently to +i18n_params+.
    # Because of this, the following constructors are identical:
    #
    #     KineticCafe::Error.new(i18n_params: { x: 1 })
    #     KineticCafe::Error.new(x: 1)
    #
    # :call-seq:
    #    new(message, options = {})
    #    new(options)
    def initialize(*args)
      options = args.last.kind_of?(Hash) ? args.pop.dup : {}
      @message = args.shift
      @message = options.delete(:message) if @message.nil? || @message.empty?
      options.delete(:message)

      @message && @message.freeze

      @status      = options.delete(:status) || default_status
      @i18n_params = options.delete(:i18n_params) || {}
      @extra       = options.delete(:extra)
      @cause       = options.delete(:cause)

      @i18n_params.update(cause: cause.message) if cause

      query = options.delete(:query)
      @i18n_params.merge!(query: stringify(query)) if query
      @i18n_params.merge!(options)
      @i18n_params.freeze
    end

    # The message associated with this exception. If not provided, defaults to
    # #i18n_message.
    def message
      @message || i18n_message
    end

    # The name of the error class.
    def name
      @name ||= KineticCafe::ErrorDSL.namify(self.class.name)
    end

    # The key used for I18n translation.
    def i18n_key
      @i18n_key ||= "#{self.class.i18n_key_base}.#{name}".freeze
    end

    # Indicates that this error should *not* have its details rendered to the
    # user, but should use the +head+ method.
    def header_only?
      false
    end

    # Indicates that this error should be rendered to the client, but clients
    # are advised *not* to display the message to the user.
    def internal?
      false
    end

    # The I18n translation of the message. If I18n.translate is defined,
    # returns #i18n_key and the I18n parameters.
    def i18n_message
      @i18n_message ||= if defined?(I18n.translate)
                          I18n.translate(i18n_key, @i18n_params).freeze
                        else
                          [ i18n_key, @i18n_params ].freeze
                        end
    end

    # The details of this error as a hash. Values that are empty or nil are
    # omitted.
    def api_error(*)
      {
        message:      @message,
        status:       status,
        name:         name,
        internal:     internal?,
        i18n_message: i18n_message,
        i18n_key:     i18n_key,
        i18n_params:  @i18n_params,
        cause:        cause && cause.message,
        extra:        extra
      }.delete_if { |_, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
    end
    alias_method :as_json, :api_error

    # An error result that can be passed as a response body.
    def error_result
      { error: api_error, message: message }
    end

    # A hash that can be passed to the Rails +render+ method with +status+ of
    # #status and +layout+ false. The +json+ field is rendered as a hash of
    # +error+ (calling #api_error) and +message+ (calling #message).
    def json_result
      { status: status, json: error_result, layout: false }
    end
    alias_method :render_json_for_rails, :json_result

    # Nice debugging version of a KineticCafe::Error
    def inspect
      "#<#{self.class}: name=#{name} status=#{status} " \
        "message=#{message.inspect} i18n_key=#{i18n_key} " \
        "i18n_params=#{@i18n_params.inspect} extra=#{extra.inspect} " \
        "cause=#{cause}>"
    end

    # The base for I18n key resolution.
    def self.i18n_key_base
      'kcerrors'.freeze
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
