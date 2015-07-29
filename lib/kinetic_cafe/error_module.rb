module KineticCafe # :nodoc:
  # The core functionality provided by a KineticCafe::Error, extracted to a
  # module to ensure that exceptions that are made hosts of error hierarchies
  # have expected functionality.
  module ErrorModule
    # The HTTP status to be returned. If not provided in the constructor, uses
    # #default_status.
    attr_reader :status
    # Extra data relevant to recipients of the exception, provided on
    # construction.
    attr_reader :extra
    ##
    # :attr_reader:
    # The exception that caused this exception. Provided on exception
    # construction or automatically through Ruby’s standard exception
    # mechanism.
    def cause
      unless @initialized_cause
        begin
          initialize_cause(super) if !@initialized_cause && super
        rescue NoMethodError
          # We are suppressing this error because Exception#cause was
          # implemented in Ruby 2.1.
          @initialized_cause = true
          @cause = nil
        end
      end

      @cause
    end

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
    #           exception. This is only necessary for Ruby before 2.1 or when
    #           directly initializing the exception.
    # +extra+:: Extra data to be returned in the API representation of this
    #           exception.
    # +query+:: A hash of parameters added to +i18n_params+, typically from
    #           Rails controller +params+ or model +where+ query. This hash
    #           will be converted into a string value similar to
    #           ActiveSupport#to_query.
    #
    # Any unmatched options will be added to +i18n_params+. Because of this,
    # the following constructors are identical:
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

      @initialized_cause = false
      @cause = nil
      initialize_cause(options.delete(:cause)) if options.key?(:cause)

      query = options.delete(:query)
      @i18n_params.merge!(query: stringify(query)) if query
      @i18n_params.merge!(options)
    end

    # The message associated with this exception. If not provided, defaults to
    # #i18n_message, which is passed the optional +locale+.
    def message(locale = nil)
      @message || i18n_message(locale)
    end

    # The name of the error class.
    def name
      @name ||= KineticCafe::ErrorDSL.namify(self.class.name)
    end

    # The key used for I18n translation.
    def i18n_key
      @i18n_key ||= if self.class.respond_to? :i18n_key
                      self.class.i18n_key
                    else
                      [
                        i18n_key_base, (name)
                      ].join('.').freeze
                    end
    end
    alias_method :code, :i18n_key

    # Indicates that this error should *not* have its details rendered to the
    # user, but should use the +head+ method.
    def header?
      false
    end
    alias_method :header_only?, :header?

    # Indicates that this error should be rendered to the client, but clients
    # are advised *not* to display the message to the user.
    def internal?
      false
    end

    # The I18n translation of the message. If I18n.translate is not defined,
    # returns #i18n_key and the I18n parameters as an array.
    #
    # If I18n is provided, the translation will be performed using the default
    # locale. The message will be cached unless +locale+ is provided, which
    # selects a specific locale for translation.
    #
    # +locale+ may be provided as a bare locale (<tt>:en</tt>) or as a hash
    # value (<tt>locale: :en</tt>).
    def i18n_message(locale = nil)
      if defined?(I18n.translate)
        case locale
        when Hash
          I18n.translate(i18n_key, @i18n_params.merge(locale))
        when nil
          @i18n_message ||= I18n.translate(i18n_key, @i18n_params).freeze
        else
          I18n.translate(i18n_key, @i18n_params.merge(locale: locale))
        end
      else
        @i18n_message ||= [ i18n_key, @i18n_params ].freeze
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

    private

    def initialize_cause(cause)
      return if cause.nil?

      unless cause.kind_of? Exception
        fail ArgumentError, 'cause must be an Exception'
      end

      @initialized_cause = true
      @cause = cause
      @i18n_params.update(cause: @cause.message)
    end

    class << self
      ##
      # The base for I18n key resolution. Defaults to 'kcerrors'.
      #
      # :method: i18n_key_base

      ##
      # The names of the expected parameters for this error. Defaults to [].
      #
      # :method: i18n_params

      ##
      # The i18n_key for the parameter. Defaults to the combination of
      # i18n_key_base and the namified version of the class (see
      # KineticCafe::ErrorDSL.namify).
      #
      # :method: i18n_key

      ##
      def included(mod)
        default_singleton_method mod, :i18n_key_base do
          'kcerrors'.freeze
        end

        default_singleton_method mod, :i18n_params do
          [].freeze
        end

        default_singleton_method mod, :i18n_key do
          @i18n_key ||= [
            i18n_key_base, KineticCafe::ErrorDSL.namify(name)
          ].join('.').freeze
        end
      end

      private

      def default_singleton_method(mod, name, &block)
        return if mod.respond_to? name
        mod.send :define_singleton_method, name, &block
      end
    end
  end
end
