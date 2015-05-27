require 'active_support/concern'

# A controller concern for KineticCafe::Error that rescues from
# KineticCafe::Error using #kinetic_cafe_error_handler. This handler can be
# redefined on a per-controller basis.
module KineticCafe::ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from KineticCafe::Error, with: :kinetic_cafe_error_handler
  end

  # This method is called with +error+ when Rails catches a KineticCafe::Error
  # descendant. It logs the message and its cause as severity error. After
  # logging, it will render to HTML or JSON.
  #
  # HTML is rendered with #kinetic_cafe_error_render_html. JSON is rendered
  # with #kinetic_cafe_error_render_json. Either of these can be overridden in
  # controllers for different behaviour.
  def kinetic_cafe_error_handler(error)
    Rails.logger.error(error.message)
    Rails.logger.error("^-- caused by: #{error.cause.message}") if error.cause

    respond_to do |format|
      format.html do
        kinetic_cafe_error_render_html(error)
      end
      format.json do
        kinetic_cafe_error_render_json(error)
      end
    end
  end

  # Render the +error+ as HTML. Uses the template +kinetic_cafe/error/page+
  # with +error+ passed as a local of the same name. The render status is set
  # to <tt>error.status</tt>.
  def kinetic_cafe_error_render_html(error)
    render template: 'kinetic_cafe/error/page', locals: { error: error },
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
end
