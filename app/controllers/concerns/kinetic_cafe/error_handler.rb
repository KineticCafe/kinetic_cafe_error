require 'active_support/concern'

# A controller concern for KineticCafe::Error that rescues from
# KineticCafe::Error using #kinetic_cafe_error_handler. This handler can be
# redefined on a per-controller basis.
module KineticCafe::ErrorHandler
  extend ActiveSupport::Concern

  included do
    kinetic_cafe_error_handler_for KineticCafe::Error

    class_attribute :__kinetic_cafe_error_handler_log_locale # :nodoc:
  end

  module ClassMethods
    # Create a new +rescue_from+ handler for the specified base class. Useful
    # if the base is not a descendant of KineticCafe::Error, but includes
    # KineticCafe::ErrorHandler.
    def kinetic_cafe_error_handler_for(klass)
      rescue_from klass, with: :kinetic_cafe_error_handler
    end

    # Logging should be done in a single language, not many languages. By
    # default, KineticCafe::Error will log errors received in the locale
    # specified by I18n.default_locale. This method can be used to change the
    # common logging locale for KineticCafe::Error handling without changing
    # I18n.default_locale.
    def kinetic_cafe_error_handler_log_locale(locale = nil)
      self.__kinetic_cafe_error_handler_log_locale = locale if locale
      self.__kinetic_cafe_error_handler_log_locale ||= I18n.default_locale
      __kinetic_cafe_error_handler_log_locale
    end
  end

  # This method is called with +error+ when Rails catches a KineticCafe::Error
  # descendant. It logs the message and its cause as severity error. After
  # logging as +error+, it will render to HTML or JSON. The received error is
  # logged using the value of #kinetic_cafe_error_handler_log_locale.
  #
  # HTML is rendered with #kinetic_cafe_error_render_html. JSON is rendered
  # with #kinetic_cafe_error_render_json. Either of these can be overridden in
  # controllers for different behaviour.
  def kinetic_cafe_error_handler(error)
    kinetic_cafe_error_log_error(error)

    respond_to do |format|
      format.html do
        kinetic_cafe_error_render_html(error)
      end
      format.json do
        kinetic_cafe_error_render_json(error)
      end
    end
  end

  # Render the +error+ as HTML. Uses the template +kinetic_cafe_error/page+
  # with +error+ passed as a local of the same name. The render status is set
  # to <tt>error.status</tt>.
  def kinetic_cafe_error_render_html(error)
    render template: 'kinetic_cafe_error/page', locals: { error: error },
      status: error.status
  end

  # Render the +error+ as JSON. If it is KineticCafe::Error#header_only?, only
  # a +head+ of the <tt>error.status</tt> is returned. Otherwise, the render is
  # done with KineticCafe::Error#json_result.
  #
  # If you are overriding this because you want to add or change #json_result,
  # use #error_result as the value to the +json+ parameter.
  #
  #   def kinetic_cafe_error_render_json(error)
  #     render status: error.status, layout: false, json: error.error_result,
  #       content_type: 'application/hal+json'
  #   end
  def kinetic_cafe_error_render_json(error)
    if error.header_only?
      head error.status
    else
      render error.json_result
    end
  end

  # Write the provided error to the Rails log using the value of
  # #kinetic_cafe_error_handler_log_locale. If the error has a cause, log
  # that as well.
  def kinetic_cafe_error_log_error(error)
    locale = self.class.kinetic_cafe_error_handler_log_locale
    Rails.logger.error(error.message(locale))

    return unless error.cause

    Rails.logger.error(
      t(
        'kinetic_cafe_error.cause',
        message: error.cause.message,
        locale: locale
      )
    )
  end
end
