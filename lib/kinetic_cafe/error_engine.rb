module KineticCafe
  # If Rails is defined, KineticCafe::ErrorEngine will be loaded automatically,
  # providing access to the KineticCafe::ErrorHandler.
  class ErrorEngine < ::Rails::Engine
    rakefile = "#{__dir__}/error_tasks.rake"
    rake_tasks do
      load rakefile
    end
  end
end
