require 'test_helper'
require 'rack/test'

describe KineticCafe::Error, '.hierarchy' do
  describe '(class: :My)' do
    def my(&block)
      KineticCafe::Error.hierarchy(class: :My, &block)
    end

    it 'creates a new object' do
      my
      assert Object.const_defined?(:My)
    end

    it 'descends from KineticCafe::Error' do
      my
      assert My < KineticCafe::Error
    end

    it 'has been extended with KineticCafe::ErrorDSL' do
      my
      assert My.singleton_class < KineticCafe::ErrorDSL
    end

    it 'yields self if a block with an argument is given' do
      my do |err|
        assert_same My, err
      end
    end

    it 'runs instance_exec against self if a no-argument block is given' do
      assert my { My == self }
    end

    it 'cannot be extended a second time' do
      my
      ex = assert_raises do
        KineticCafe::Error.hierarchy(class: :My)
      end
      assert_match(/is already a root hierarchy/, ex.message)
    end

    after do
      Object.send(:remove_const, :My) if Object.const_defined?(:My)
    end
  end

  describe '(class: :My, namespace: Foo)' do
    before do
      Foo = Module.new
      KineticCafe::Error.hierarchy(class: :My, namespace: Foo)
    end

    it 'creates a new object' do
      assert Foo.const_defined?(:My)
    end

    it 'descends from KineticCafe::Error' do
      assert Foo::My < KineticCafe::Error
    end

    it 'has been extended with KineticCafe::ErrorDSL' do
      assert Foo::My.singleton_class < KineticCafe::ErrorDSL
    end

    it 'cannot be extended a second time' do
      ex = assert_raises do
        KineticCafe::Error.hierarchy(class: :My, namespace: Foo)
      end
      assert_match(/is already a root hierarchy/, ex.message)
    end

    after do
      Foo.send(:remove_const, :My) if Foo.const_defined?(:My)
      Object.send(:remove_const, :Foo) if Object.const_defined?(:Foo)
    end
  end

  describe '(class: My)' do
    describe 'when My is a StandardError' do
      before do
        My = Class.new(StandardError)
        KineticCafe::Error.hierarchy(class: My)
      end

      it 'has been extended with KineticCafe::ErrorDSL' do
        assert My.singleton_class < KineticCafe::ErrorDSL
      end

      it 'has KineticCafe::ErrorModule included' do
        assert My < KineticCafe::ErrorModule
      end

      it 'can handle a query parameter (issue #9)' do
        expected = { query: "id: 1" }
        actual = My.new(query: { id: 1 }).instance_variable_get(:@i18n_params)
        assert_equal expected, actual
      end

      it 'cannot be extended a second time' do
        ex = assert_raises do
          KineticCafe::Error.hierarchy(class: :My)
        end
        assert_match(/is already a root hierarchy/, ex.message)
      end

      after do
        Object.send(:remove_const, :My) if Object.const_defined?(:My)
      end
    end

    it 'fails if My is not an Exception' do
      ex = assert_raises do
        KineticCafe::Error.hierarchy(class: Class.new)
      end
      assert_match(/cannot root.*StandardError/, ex.message)
    end

    it 'fails if My is not a StandardError' do
      assert_raises do
        KineticCafe::Error.hierarchy(class: Class.new(Exception))
      end
    end
  end

  describe '(class: :My, rack_status: option)' do
    def my(option, &block)
      KineticCafe::Error.hierarchy(class: :My, rack_status: option, &block)
    end

    it 'disables method and object creation when rack_status: false' do
      my(false)
      refute My.const_defined?(:NotFound)
      refute My.respond_to?(:not_found)
    end

    it 'disables method creation when rack_status: { methods: false }' do
      my(methods: false)
      assert My.const_defined?(:NotFound)
      refute My.respond_to?(:not_found)
    end

    it 'disables object creation when rack_status: { errors: false }' do
      my(errors: false)
      refute My.const_defined?(:NotFound)
      assert My.respond_to?(:not_found)
    end

    after do
      Object.send(:remove_const, :My) if Object.const_defined?(:My)
    end
  end
end
