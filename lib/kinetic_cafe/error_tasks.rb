# frozen_string_literal: true

module KineticCafe
  # Tasks to assist with managing kinetic_cafe_error classes in Rake.
  module ErrorTasks #:nodoc:
    extend Rake::DSL
  end
end

##
module KineticCafe::ErrorTasks #:nodoc:
  require 'kinetic_cafe_error'

  namespace :kcerror do
    desc 'Show defined errors.'
    task :defined, [ :params ] => 'kcerror:find' do |_, args|
      display = ->(root, prefix: '', show_params: false) {
        line = "#{prefix}- #{root}"

        if !root.i18n_params.empty? && show_params
          line << ' (' << root.i18n_params.join(', ') << ')'
        end

        puts line

        if @descendants[root]
          sorted = @descendants[root].sort_by(&:to_s)
          sorted.each do |child|
            s = (child == sorted.last) ? '`' : '|'
            display.(
              child,
              prefix: "#{prefix.tr('|`', ' ')}  #{s}",
              show_params: show_params
            )
          end
        end
      }

      show_params = args.params =~ /^y/i

      if @descendants[StandardError]
        @descendants[StandardError].sort_by(&:to_s).each { |d|
          display.(d, show_params: show_params)
        }
      else
        puts 'No defined errors.'
      end
    end

    desc 'Generate a sample translation key file.'
    task :translations, [ :output ] => 'kcerror:find' do |_, args|
      translations = {}
      traverse = ->(root) {
        translation = (translations[root.i18n_key_base] ||= {})
        name = KineticCafe::ErrorDSL.namify(root)

        params = root.i18n_params.map { |param| "%{#{param}}" }.join(' ')

        if params.empty?
          translation[name] = "Translation for #{name} with no params."
        else
          translation[name] = "Translation for #{name} with #{params}."
        end

        if @descendants[root]
          @descendants[root].sort_by(&:to_s).each { |child| traverse.(child) }
        end
      }

      if @descendants[StandardError]
        @descendants[StandardError].sort_by(&:to_s).each do |d| traverse.(d) end

        # Normal YAML dump does not match the pattern that we want to compare
        # against. Therefore, we are going to write this file manually.
        text = 'kc:'

        translations.keys.sort.each do |group|
          text << "\n  #{group}:"

          translations[group].keys.sort.each { |k|
            text << "\n    #{k}: >-\n      #{translations[group][k]}"
          }
        end

        if args.output
          File.open(args.output, 'w') { |f| f.puts text }
        else
          puts text
        end
      end
    end

    task :find do
      @descendants = {}
      ObjectSpace.each_object(Class) do |k|
        next unless k.singleton_class < KineticCafe::ErrorDSL

        (@descendants[k.superclass] ||= []) << k
      end
    end
  end
end
