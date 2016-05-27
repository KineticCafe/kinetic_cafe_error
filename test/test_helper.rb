# -*- ruby encoding: utf-8 -*-
# frozen_string_literal: true

gem 'minitest'
require 'minitest/autorun'
require 'minitest/focus'
require 'minitest/moar'
require 'minitest/stub_const'
require 'minitest-bonus-assertions'
require 'rack/test'
require 'yaml'
require 'kinetic_cafe_error'

puts "Testing with Rack.release #{Rack.release}"

unless defined? I18n.translate
  module I18n
    def self.translate(*)
    end
  end
end
