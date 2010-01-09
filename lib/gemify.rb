$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'rubygems/builder'
require 'yaml'
require 'open3'

require 'gemify/base'
require 'gemify/manifest'
require 'gemify/cli'

module Gemify
  class << self; attr_accessor :last_specification; end
end

# Force Gem::Specification to use Gemify::Base instead.
Gem::Specification.extend Module.new { 
  def new(*args, &blk)
    if self == Gem::Specification
      Gemify::Base.new(*args, &blk)
    else
      Gemify.last_specification = super
    end
  end
}

Gem::DefaultUserInteraction.ui = Gem::SilentUI.new
