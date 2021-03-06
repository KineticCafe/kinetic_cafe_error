# frozen_string_literal: true
require 'test_helper'

describe KineticCafe::Error do
  describe 'defaults' do
    let(:exception) { @exception = KineticCafe::Error.new }

    it 'defaults correctly' do
      stub I18n, :translate, 'Untranslatable error' do
        expected = '#<KineticCafe::Error: name=error ' \
          'status=bad_request severity=error message="Untranslatable error" ' \
          'i18n_key=kcerrors.error i18n_params={} extra=nil cause=>'
        assert_equal expected, exception.inspect
      end
    end

    describe '#message and #i18n_message' do
      it 'returns key/params if I18n.translate is not defined' do
        Object.stub_remove_const(:I18n) do
          assert_equal [ 'kcerrors.error', {} ], exception.i18n_message
        end
      end

      it 'encodes the :query parameter specially for I18n parameters' do
        query = {
          a: 1,
          b: %w(x y z),
          c: [ d: 1, e: 2 ],
          f: []
        }

        exception = KineticCafe::Error.new(query: query)
        Object.stub_remove_const(:I18n) do
          assert_equal(
            [
              'kcerrors.error',
              { query: 'a: 1; b[]: x, b[]: y, b[]: z; c[][d]: 1; c[][e]: 2; f[]: []' }
            ],
            exception.i18n_message
          )
        end
      end

      it 'calls I18n.translate if defined' do
        matcher = ->(key, options) {
          assert_equal 'kcerrors.error', key
          assert_kind_of Hash, options
          assert_missing_keys options, :locale
        }

        stub I18n, :translate, matcher do
          exception.i18n_message
        end
      end

      it 'calls I18n.translate with a bare locale if given one' do
        matcher = ->(key, options) {
          assert_equal 'kcerrors.error', key
          assert_kind_of Hash, options
          assert_has_keys options, :locale
          assert_equal :kc, options[:locale]
        }

        stub I18n, :translate, matcher do
          exception.i18n_message(:kc)
        end
      end

      it 'calls I18n.translate with a hash locale if given one' do
        matcher = ->(key, options) {
          assert_equal 'kcerrors.error', key
          assert_kind_of Hash, options
          assert_has_keys options, :locale
          assert_equal :kc, options[:locale]
        }

        stub I18n, :translate, matcher do
          exception.i18n_message(locale: :kc)
        end
      end

      it '#message fowards to #i18n_message if no @message' do
        stub exception, :i18n_message do
          exception.message
        end

        assert_instance_called exception, :i18n_message
      end
    end

    it '#api_error only includes set values' do
      assert_equal(
        {
          status: :bad_request,
          severity: :error,
          name: 'error',
          internal: false,
          i18n_key: 'kcerrors.error'
        },
        exception.api_error
      )
    end

    it '#error_result includes #api_error and #message' do
      assert_equal(
        {
          error: {
            status: :bad_request,
            severity: :error,
            name: 'error',
            internal: false,
            i18n_key: 'kcerrors.error'
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
              severity: :error,
              name: 'error',
              internal: false,
              i18n_key: 'kcerrors.error'
            },
            message: nil
          },
          layout: false
        },
        exception.json_result
      )
    end

    it 'is not #header? by default' do
      refute exception.header?
    end

    it 'is not #internal? by default' do
      refute exception.internal?
    end

    it 'has no I18n parameters by default' do
      assert_empty KineticCafe::Error.i18n_params
    end
  end

  describe 'handles causing exceptions' do
    before do
      begin
        begin
          fail 'causing'
        rescue => ex
          @causing_exception = ex
          raise KineticCafe::Error, cause: @causing_exception, message: 'wrapping'
        end
      rescue => ex
        @wrapping_exception = ex
      end
    end

    it 'captures the causing exception' do
      refute_nil @wrapping_exception.cause, 'No exception captured'
      assert_equal @causing_exception, @wrapping_exception.cause
    end

    it 'puts the cause message in i18n_params when the cause is requested' do
      refute_nil @wrapping_exception.cause, 'No exception captured'
      assert_equal(
        { cause: 'causing' },
        @wrapping_exception.instance_variable_get(:@i18n_params)
      )
    end
  end
end
