# frozen_string_literal: true

require 'test_helper'
require 'kinetic_cafe/error_tasks'

describe KineticCafe::ErrorTasks do
  def setup
    Object.const_set(:My, Module.new)
    KineticCafe::Error.hierarchy(class: :Base, namespace: My, rack_status: { errors: false }) do
      define_error class: :child, status: :not_found, i18n_params: %i(query)
      define_error key: :other_child, status: :bad_request do
        define_error key: :sub_child, status: :im_a_teapot
      end
    end
  end

  def teardown
    Object.send(:remove_const, :My)
  end

  describe '.print_defined' do
    describe 'when no StandardError descendants' do
      it 'prints no defined errors' do
        io = StringIO.new
        KineticCafe::ErrorTasks.print_defined({}, { output: io })

        assert_match(/No defined errors./, io.string)
      end
    end

    describe 'when data' do
      it 'prints out the classes involved, sorted' do
        io = StringIO.new

        classes = [
          My::Base,
          My::Base::ChildNotFound, My::Base::OtherChild,
          My::Base::OtherChild::SubChild
        ]
        descendants = KineticCafe::ErrorTasks.send(:build_error_hierarchy, classes)
        KineticCafe::ErrorTasks.print_defined(descendants, output: io)

        expected = [
          'KineticCafe::Error',
          'My::Base',
          'My::Base::ChildNotFound',
          'My::Base::OtherChild',
          'My::Base::OtherChild::SubChild'
        ]
        actual = io.string.scan(/ \w.+\n/).map(&:strip)

        assert_equal expected, actual
      end
    end
  end

  describe '.print_translation_yaml' do
    describe 'when no StandardError descendant' do
      it 'prints no defined errors' do
        io = StringIO.new
        KineticCafe::ErrorTasks.print_defined({}, { output: io })

        assert_match(/No defined errors./, io.string)
      end
    end

    describe 'when data' do
      it 'prints the correct data in YAML format' do
        io = StringIO.new

        classes = [
          My::Base,
          My::Base::ChildNotFound, My::Base::OtherChild,
          My::Base::OtherChild::SubChild
        ]
        descendants = KineticCafe::ErrorTasks.send(:build_error_hierarchy, classes)
        KineticCafe::ErrorTasks.print_translation_yaml(descendants, output: io)

        expected = { 'kc' =>
                    { 'kcerrors' =>
                     {
                       'base' => 'Translation for base with no params.',
                       'child_not_found' => 'Translation for child_not_found with %{query}.',
                       'error' => 'Translation for error with no params.',
                       'other_child' => 'Translation for other_child with no params.',
                       'sub_child' => 'Translation for sub_child with no params.'
                     } } }

        actual = YAML.load(io.string)

        assert_equal expected, actual
      end
    end
  end
end
