require 'test_helper'

describe KineticCafe::Error do
  describe 'defaults' do
    let(:exception) { @exception = KineticCafe::Error.new }

    it 'defaults correctly' do
      stub I18n, :translate, 'Untranslatable error' do
        expected = '#<KineticCafe::Error: name=error ' \
          "status=bad_request message=\"Untranslatable error\" " \
          'i18n_key=kcerrors.error i18n_params={} extra=nil cause=>'
        assert_equal expected, exception.inspect
      end
    end

    it 'returns key/params if I18n.translate is not defined' do
      Object.stub_remove_const(:I18n) do
        assert_equal [ 'kcerrors.error', {} ], exception.i18n_message
      end
    end

    it '#api_error only includes set values' do
      assert_equal(
        {
          status: :bad_request,
          name: "error",
          internal: false,
          i18n_key: "kcerrors.error"
        },
        exception.api_error
      )
    end

    it '#error_result includes #api_error and #message' do
      assert_equal(
        {
          error: {
            status: :bad_request,
            name: "error",
            internal: false,
            i18n_key: "kcerrors.error"
          },
          message: nil
        },
        exception.error_result
      )
    end

    it '#json_result includes #status, #error_result, and layout: false' do
      assert_equal(
        {
          status: :bad_request,
          json: {
            error: {
              status: :bad_request,
              name: "error",
              internal: false,
              i18n_key: "kcerrors.error"
            },
            message: nil
          },
          layout: false
        },
        exception.json_result
      )
    end

    it 'encodes the :query parameter specially for I18n parameters' do
      exception = KineticCafe::Error.new(query: { a: 1, b: %w(x y z )})
      Object.stub_remove_const(:I18n) do
        assert_equal(
          [
            'kcerrors.error',
            { query: "a: 1; b[]: x, b[]: y, b[]: z" }
          ],
          exception.i18n_message
        )
      end
    end
  end
end
