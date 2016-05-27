# frozen_string_literal: true

require 'kinetic_cafe_error'

module KineticCafe
  # Tasks to assist with managing kinetic_cafe_error classes in Rake.
  module ErrorTasks #:nodoc:
    require 'rake' unless defined?(::Rake)

    extend ::Rake::DSL
  end
end

class << KineticCafe::ErrorTasks
  def print_defined(descendants = @descendants, output: $stdout, params: false)
    if descendants[::StandardError].nil? || descendants[::StandardError].empty?
      output.puts 'No defined errors.'
    else
      descendants[::StandardError].sort_by(&:to_s).each { |d|
        display_error_class(descendants, d, output: output, params: params)
      }
    end
  end

  def print_translation_yaml(descendants = @descendants, output: $stdout)
    output.puts build_translation_yaml(descendants)
  end

  private

  def display_error_class(descendants, root, output: $stdout, prefix: '', params: false)
    line = String.new("#{prefix}- #{root}")

    if !root.i18n_params.empty? && params
      line << ' (' << root.i18n_params.join(', ') << ')'
    end

    output.puts line

    if descendants[root]
      sorted = descendants[root].sort_by(&:to_s)
      sorted.each do |child|
        s = (child == sorted.last) ? '`' : '|'
        display_error_class(
          descendants,
          child,
          output: output,
          prefix: "#{prefix.tr('|`', ' ')}  #{s}",
          params: params
        )
      end
    end
  end

  def build_error_hierarchy(error_class_list)
    Hash.new { |h, k| h[k] = [] }.tap do |hierarchy|
      error_class_list.each do |error_class|
        hierarchy[error_class.superclass] << error_class
      end

      hierarchy[::StandardError].push(
        *(
          hierarchy.keys.select { |r| r.superclass == ::StandardError } -
          hierarchy[::StandardError]
        )
      )
    end
  end

  def find_with_error_dsl_inheritors
    @descendants = build_error_hierarchy(KineticCafe::ErrorDSL.inheritors)
  end

  def collect_translations(descendants, translations, root)
    translation = (translations[root.i18n_key_base] ||= {})
    name = KineticCafe::ErrorDSL.namify(root)

    params = root.i18n_params.map { |param| "%{#{param}}" }.join(' ')

    translation[name] = if params.empty?
                          "Translation for #{name} with no params."
                        else
                          "Translation for #{name} with #{params}."
                        end

    if descendants[root]
      descendants[root].sort_by(&:to_s).each do |child|
        collect_translations(descendants, translations, child)
      end
    end
  end

  def find_translations(descendants)
    {}.tap do |translations|
      descendants[::StandardError].sort_by(&:to_s).each do |d|
        collect_translations(descendants, translations, d)
      end
    end
  end

  def build_translation_yaml(descendants)
    translations = find_translations(descendants)
    return if translations.empty?

    # Normal YAML dump does not match the pattern that we want to compare
    # against. Therefore, we are going to write this file manually.
    String.new('kc:').tap do |text|
      translations.keys.sort.each do |group|
        text << "\n  #{group}:"

        translations[group].keys.sort.each { |k|
          text << "\n    #{k}: >-\n      #{translations[group][k]}"
        }
      end
    end
  end

  def save_translation_yaml(filename, descendants = @descendants)
    File.open(filename, 'w') { |f| print_translation_yaml(descendants, output: f) }
  end
end

##
module KineticCafe::ErrorTasks #:nodoc:
  namespace :kcerror do
    desc 'Show defined errors.'
    task :defined, [ :params ] => 'kcerror:find' do |_, args|
      print_defined(params: args.params =~ /^y/i)
    end

    desc 'Generate a sample translation key file.'
    task :translations, [ :output ] => 'kcerror:find' do |_, args|
      if args.output
        save_translation_yaml(args.output)
      else
        print_translation_yaml
      end
    end

    task :find do
      find_with_error_dsl_inheritors
    end
  end
end
