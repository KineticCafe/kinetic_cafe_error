require 'rspec/expectations'

module KineticCafe
  # Provide a number of useful expectations against Kinetic Cafe errors. Enable
  # these with:
  #
  #   require 'kinetic_cafe/error_rspec'
  #   RSpec.configure do |c|
  #     c.include KineticCafe::ErrorRSpec
  #   end
  #
  # +be_json_for+:: Verifies that the expected value is a JSON representation
  #                 of the actual value. If the actual value responds to
  #                 #body, the actual value is replaced with +actual.body+.
  #
  # +be_kc_error+:: Verifies that the expected value is a KineticCafe::Error.
  #
  # +be_kc_error_json+:: Verifies that the JSON value matches the output of
  #                      KineticCafe::Error.
  #
  # +be_kc_error_html+:: Verifies that the rendered HTML matches the output of
  #                      KineticCafe::Error.
  module ErrorRSpec
    extend ::RSpec::Matchers::DSL

    matcher :be_json_for do |expected|
      match do |actual|
        compare = if actual.respond_to?(:body)
                    actual.body
                  else
                    compare
                  end
        expect(JSON.parse(compare)).to eq(expected)
      end

      diffable
    end

    matcher :be_kc_error do |expected, params = {}|
      match do |actual|
        expect(actual).to be_kind_of(KineticCafe::ErrorModule)
        expect(actual).to be_kind_of(expected)
        expect(actual).to eq(expected.new(params))
      end

      diffable
    end

    matcher :be_kc_error_json do |expected, params = {}|
      match do |actual|
        expect(actual).to \
          be_json_for(JSON.parse(expected.new(params).error_result.to_json))
      end

      diffable
    end

    matcher :be_kc_error_html do |expected|
      match do |actual|
        expect(actual).to render_template('kinetic_cafe_error/page')
        expect(actual).to render_template('kinetic_cafe_error/_table')
        expect(actual).to include(expected.i18n_key)
      end
    end
  end
end
