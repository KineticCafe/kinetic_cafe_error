namespace :kcerror do
  desc 'Show defined errors.'
  task defined: 'kcerror:find' do
    display = ->(root, prefix = '') {
      puts "#{prefix}- #{root}"

      if @descendants[root]
        sorted = @descendants[root].sort_by(&:to_s)
        sorted.each do |child|
          s = (child == sorted.last) ? '`' : '|'
          display.(child, "#{prefix.tr('|`', ' ')}  #{s}")
        end
      end
    }

    @descendants[StandardError].sort_by(&:to_s).each { |d| display.(d) }
  end

  desc 'Generate a sample translation key file.'
  task :translations, [ :output ] => 'kcerror:find' do |_, args|
    translations = {}
    traverse = ->(root) {
      translation = (translations[root.i18n_key_base] ||= {})
      name = KineticCafe::ErrorDSL.namify(root)

      params = root.i18n_params.map { |param| "%{#{param}}" }.join(' ')

      if params.empty?
        translation[name] = %Q(Translation for #{name} with no params.)
      else
        translation[name] = %Q(Translation for #{name} with #{params}.)
      end

      if @descendants[root]
        @descendants[root].sort_by(&:to_s).each { |child| traverse.(child) }
      end
    }

    @descendants[StandardError].sort_by(&:to_s).each { |d| traverse.(d) }

    require 'yaml'
    translations = YAML.dump({ 'en' => translations })

    if args.output
      File.open(args.output, 'w') { |f| f.write translations }
    else
      puts translations
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
