#!/usr/bin/env ruby
require 'rubygems'

unless p = ARGV[0]
  puts "gemify <program>"
  exit
end

unless File.exists?(p) && !File.directory?(p)
  puts "File not found: '#{p}'"
  exit
end

@config = {}

bin = p[-3..-1] != ".rb"
@config[:name] = bin ? p : p[0..-4]

%w[summary version author email].each{|x|print x.capitalize + "? ";@config[x.to_sym]=$stdin.gets.strip}

print "Dependecies? "
dep = []
if $stdin.gets.strip.downcase[0] == ?y
  puts "Write one dependecie on each line. Add an extra line when you are finish."
  while !(s=$stdin.gets.strip).empty?
    dep << s
  end
end

Gem::Builder.new(Gem::Specification.new do |s|
  s.name = @config[:name]
  s.author = @config[:author]
  s.email = @config[:email]
  s.version = @config[:version]
  s.summary = @config[:summary]
  s.platform = Gem::Platform::RUBY
  s.files = [p]
  
  if bin
    s.bindir = "."
    s.executables << p
  else
    s.require_path = "."
  end
  
  dep.each do |d|
    s.add_dependency d
  end
end).build