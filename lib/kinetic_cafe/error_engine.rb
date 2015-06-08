module KineticCafe
  # If Rails is defined, KineticCafe::ErrorEngine will be loaded automatically,
  # providing access to the KineticCafe::ErrorHandler.
  class ErrorEngine < ::Rails::Engine
    rake_tasks do
      load "#{__dir__}/error_tasks.rake"
    end
  end
end
