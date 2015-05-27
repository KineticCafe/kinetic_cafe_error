require 'test_helper'
require 'rack/test'

describe KineticCafe::ErrorDSL do
  it 'cannot be extended onto a non-exception' do
    ex = assert_raises RuntimeError do
      Class.new.send(:extend, KineticCafe::ErrorDSL)
    end
    assert_match(/cannot extend.*StandardError/, ex.message)
  end

  it 'cannot be extended onto a non-StandardError' do
    ex = assert_raises RuntimeError do
      Class.new(Exception).send(:extend, KineticCafe::ErrorDSL)
    end
    assert_match(/cannot extend.*StandardError/, ex.message)
  end

  it 'cannot be included' do
    ex = assert_raises RuntimeError do
      Class.new.send(:include, KineticCafe::ErrorDSL)
    end
    assert_match(/cannot be included/, ex.message)
  end

  describe 'Descendant of Standard Error' do
    let(:base) {
      Class.new(StandardError) do
        extend KineticCafe::ErrorDSL
      end
    }
    let(:instance) { child.new }

    it 'responds to #define_error' do
      assert base.respond_to?(:define_error)
    end

    describe '#define_error' do
      describe 'fails when' do
        it 'given bad options' do
          ex = assert_raises ArgumentError do
            base.define_error 'bad options'
          end
          assert_equal 'invalid options', ex.message
        end

        it 'given empty options' do
          ex = assert_raises ArgumentError do
            base.define_error({})
          end
          assert_equal 'define what error?', ex.message
        end

        it 'provided both :key and :class' do
          ex = assert_raises ArgumentError do
            base.define_error key: :bar, class: :bar
          end
          assert_equal ':key conflicts with class:bar', ex.message
        end

        it 'missing both :key and :class' do
          ex = assert_raises ArgumentError do
            base.define_error status: 300
          end
          assert_equal 'one of :key or :class must be provided', ex.message
        end

        it 'the exception class already exists' do
          base.define_error class: :bar, status: :missing
          ex = assert_raises ArgumentError do
            base.define_error class: :bar, status: :missing
          end
          assert_equal 'key:bar_missing already exists as BarMissing with class:bar',
            ex.message
        end
      end

      describe 'key-based definition' do
        let(:child) { base.define_error key: :child }

        it 'returns "child" for #name' do
          refute base.public_instance_methods.include?(:name)
          assert_equal 'child', instance.name
        end

        it 'returns "kcerrors.child" for #i18n_key' do
          refute base.public_instance_methods.include?(:i18n_key)
          assert_equal 'kcerrors.child', instance.i18n_key
        end

        it 'returns :bad_request for #default_status (private)' do
          refute base.private_instance_methods.include?(:default_status)
          assert_equal :bad_request, instance.send(:default_status)
        end

        it 'returns 400 for #default_status without Rack::Utils (private)' do
          Rack.stub_remove_const(:Utils) do
            refute base.private_instance_methods.include?(:default_status)
            assert_equal 400, instance.send(:default_status)
          end
        end
      end

      describe 'class-based definition' do
        describe 'without status' do
          before do
            KineticCafe.send(:const_set, :TestError, base)
          end

          after do
            KineticCafe.send(:remove_const, :TestError)
          end

          let(:child) { base.define_error class: :child }

          it 'is called ChildTestError' do
            assert child && base.const_defined?(:ChildTestError)
          end

          it 'returns "child_test_error" for #name' do
            refute base.public_instance_methods.include?(:name)
            assert_equal 'child_test_error', instance.name
          end

          it 'returns "kcerrors.child_test_error" for #i18n_key' do
            refute base.public_instance_methods.include?(:i18n_key)
            assert_equal 'kcerrors.child_test_error', instance.i18n_key
          end

          it 'returns :bad_request for #default_status (private)' do
            refute base.private_instance_methods.include?(:default_status)
            assert_equal :bad_request, instance.send(:default_status)
          end

          it 'returns 400 for #default_status without Rack::Utils (private)' do
            Rack.stub_remove_const(:Utils) do
              refute base.private_instance_methods.include?(:default_status)
              assert_equal 400, instance.send(:default_status)
            end
          end
        end

        describe 'with symbol status' do
          let(:child) {
            base.define_error class: :child, status: :not_found
          }

          it 'is called ChildNotFound' do
            assert child && base.const_defined?(:ChildNotFound)
          end

          it 'returns "child_not_found" for #name' do
            refute base.public_instance_methods.include?(:name)
            assert_equal 'child_not_found', instance.name
          end

          it 'returns "kcerrors.child_not_found" for #i18n_key' do
            refute base.public_instance_methods.include?(:i18n_key)
            assert_equal 'kcerrors.child_not_found', instance.i18n_key
          end

          it 'returns :not_found for #default_status (private)' do
            refute base.private_instance_methods.include?(:default_status)
            assert_equal :not_found, instance.send(:default_status)
          end
        end

        describe 'with numeric status' do
          before do
            KineticCafe.send(:const_set, :TestError, base)
          end

          after do
            KineticCafe.send(:remove_const, :TestError)
          end

          let(:child) { base.define_error class: :child, status: 400 }

          it 'is called ChildTestError' do
            assert child && base.const_defined?(:ChildTestError)
          end

          it 'returns "child_test_error" for #name' do
            refute base.public_instance_methods.include?(:name)
            assert_equal 'child_test_error', instance.name
          end

          it 'returns "kcerrors.child_test_error" for #i18n_key' do
            refute base.public_instance_methods.include?(:i18n_key)
            assert_equal 'kcerrors.child_test_error', instance.i18n_key
          end

          it 'returns 400 for #default_status (private)' do
            refute base.private_instance_methods.include?(:default_status)
            assert_equal 400, instance.send(:default_status)
          end
        end
      end

      it 'defines #header_only? if requested' do
        child = base.define_error key: :foo, header_only: true
        assert child.new.header_only?
      end

      it 'squeezes out extra underscores' do
        base.define_error key: :_foo__bar_
        assert base.const_defined?(:FooBar)
      end

      it 'defines a new exception descended from the base, in the base namespace' do
        refute base.const_defined?(:BarMissing)
        base.define_error class: :bar, status: :missing
        assert base.const_defined?(:BarMissing)
        assert base::BarMissing < base
      end
    end
  end
end
