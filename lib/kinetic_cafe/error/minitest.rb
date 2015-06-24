module Minitest #:nodoc:
  # Add assertions to Minitest for testing KineticCafe::Error objects.
  module KineticCafeErrorAssertions
    # Assert that the +actual+ exception received is the +expected+ descendant
    # of KineticCafe::Error and that it has been constructed with the same
    # +params+ provided.
    def assert_kc_error expected, actual, params = {}, msg = nil
      msg, params = params, {} if msg.nil? && params.kind_of?(String)

      assert_kind_of KineticCafe::ErrorModule, actual,
        msg || "Expected #{actual} to be #{expected}, but it was not."

      assert_kind_of expected, actual,
        msg || "Expected #{actual} to be #{expected}, but it was not."

      expected = expected.new(params)
      assert_equal expected, actual,
        msg || "Expected #{actual} to be #{expected}, but it was not."
    end

    # Assert that the +actual+ string received is the +expected+ descendant of
    # KineticCafe::Error and that it has been constructed with the same
    # +params+ provided.
    #
    # This differs from +assert_kc_error+ in that comparison of the parsed JSON
    # output is compared, not KineticCafe::Error objects. The JSON for the
    # provided KineticCafe::Error object is generated through
    # KineticCafe::Error#error_json.
    def assert_kc_error_json expected, actual, params = {}, msg = nil
      msg, params = params, {} if msg.nil? && params.kind_of?(String)

      msg ||= "Expected #{actual} to be JSON for #{expected}, but it was not."
      actual = JSON.parse(actual)
      expected = JSON.parse(expected.new(params).error_result.to_json)

      assert_equal expected, actual, msg
    end

    # Assert that a reponse body (<tt>@response.body</tt>, useful from
    # ActionController::TestCase) is HTML for the expected error.
    def assert_response_kc_error_html expected, msg = nil
      msg ||= "Expected #{actual} to be HTML for #{expected}, but it was not."

      assert_template 'kinetic_cafe_error/page', msg
      assert_template 'kinetic_cafe_error/_table', msg

      assert_match(/#{expected.i18n_key}/, @response.body, msg)
      assert_response expected.new.status, msg
    end

    # Assert that a reponse body (<tt>@response.body</tt>, useful from
    # ActionController::TestCase) is JSON for the expected error. This is a
    # convenience wrapper around #assert_kc_error_json or
    # #assert_kc_error_html, depending on whether or not the response is HTML
    # or not.
    def assert_response_kc_error expected, params = {}, msg = nil
      msg, params = params, {} if msg.nil? && params.kind_of?(String)
      msg ||= "Expected response to be #{expected}, but was not."

      if @request.format.html?
        assert_response_kc_error_html expected, msg
      else
        assert_kc_error_json expected, @response.body, params, msg
      end
    end

    Minitest::Test.send(:include, self)
  end

  # Extend Minitest::Expectations with expectations for KineticCafe::Error
  # tests.
  module Expectations
    ##
    # See Minitest::KineticCafeErrorAssertions#assert_kc_error
    #
    # :method: must_be_kc_error expected, params = {}, msg = nil

    infect_an_assertion :assert_kc_error, :must_be_kc_error, :dont_flip

    ##
    # See Minitest::KineticCafeErrorAssertions#assert_kc_error_json
    #
    # :method: must_be_kc_error_json expected, params = {}, msg = nil

    infect_an_assertion :assert_kc_error_json, :must_be_kc_error_json,
      :dont_flip
  end
end
