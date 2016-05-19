# frozen_string_literal: true
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
  # logged using the value of #kinetic_cafe_error_handler_log_locale. After
  # rendering to HTML or JSON, +error+ will be passed to a post-processing
  # handler.
  #
  # HTML is rendered with #kinetic_cafe_error_render_html. JSON is rendered
  # with #kinetic_cafe_error_render_json. Either of these can be overridden in
  # controllers for different behaviour.
  #
  # The +error+ is passed to #kinetic_cafe_error_handle_post_error to be
  # handled for post-processing. This should be overridden to implement
  # post-processing, for example passing the error to an external error
  # capturing/tracking service such as Airbrake or Sentry.
  #
  # As an option, +kinetic_cafe_error_handler+ can also be used in a
  # +rescue_from+ block with an error class and parameters, and it will
  # construct the error for handling. The following example assumes that there
  # is an error called ObjectNotFound.
  #
  #   rescue_from ActiveRecord::NotFound do |error|
  #     kinetic_cafe_error_handler KineticCafe::Error::ObjectNotFound,
  #       cause: error
  #   end
  #
  # This would be the same as:
  #
  #   rescue_from ActiveRecord::NotFound do |error|
  #     kinetic_cafe_error_handler KineticCafe::Error::ObjectNotFound.new(
  #       cause: error
  #     )
  #   end
  def kinetic_cafe_error_handler(error, error_params = {})
    # If the error provided is actually an error class, make an error instance.
    error.kind_of?(KineticCafe::ErrorDSL) && error = error.new(error_params)

    kinetic_cafe_error_log_error(error)

    if respond_to?(:respond_to)
      respond_to do |format|
        format.html do
          kinetic_cafe_error_render_html(error)
        end
        format.json do
          kinetic_cafe_error_render_json(error)
        end
      end
    else
      kinetic_cafe_error_render_json(error)
    end

    kinetic_cafe_error_handle_post_error(error)
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

  def kinetic_cafe_error_handle_post_error(_error)
  end

  # Write the provided error to the Rails log using the value of
  # #kinetic_cafe_error_handler_log_locale. If the error has a cause, log
  # that as well. Rails.logger.class is expected to have constants matching
  # error.severity.upcase, which is used to determine the numeric severity
  # to log the error at.
  def kinetic_cafe_error_log_error(error)
    locale = self.class.kinetic_cafe_error_handler_log_locale
    severity = Rails.logger.class.const_get(error.severity.upcase)
    Rails.logger.add(severity, nil, error.message(locale))

    return unless error.cause

    Rails.logger.add(
      severity,
      nil,
      t(
        'kinetic_cafe_error.cause',
        message: error.cause.message,
        locale: locale
      )
    )
  end
end
