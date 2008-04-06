$:.unshift File.dirname(__FILE__)+"/../lib"
require 'gemify'

module BaseHelper
  def dummy
    {
      :name => "gemify",
      :summary => "Just another gem",
      :version => "0.9",
      :author => "Magnus Holm",
      :email => "judofyr@gmail.com",
      :homepage => "http://dojo.rubyforge.org",
      :rubyforge_project => "dojo",
      :has_rdoc => true,
      :dependencies => ["rubygems", "merb-core"]
    }
  end
end