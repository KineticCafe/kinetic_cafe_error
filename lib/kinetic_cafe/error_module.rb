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
        unless mod.respond_to?(:i18n_key_base)
          mod.send :define_singleton_method, :i18n_key_base do
            'kcerrors'.freeze
          end
        end

        unless mod.respond_to?(:i18n_params)
          mod.send :define_singleton_method, :i18n_params do
            [].freeze
          end
        end

        unless mod.respond_to?(:i18n_key)
          mod.send :define_singleton_method, :i18n_key do
            @i18n_key ||= [
              i18n_key_base, KineticCafe::ErrorDSL.namify(name)
            ].join('.').freeze
          end
        end
      end
    end
  end
end
