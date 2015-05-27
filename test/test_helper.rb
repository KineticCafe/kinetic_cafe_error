# -*- ruby encoding: utf-8 -*-

gem 'minitest'
require 'minitest/autorun'
require 'minitest/stub_const'
require 'minitest/moar'
require 'rack/test'
require 'kinetic_cafe_error'

unless defined? I18n.translate
  module I18n
    def self.translate(*)
    end
  end
end
