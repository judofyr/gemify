require 'rubygems'
require 'yaml'

class Gemify
  REQUIRED = [:name, :summary, :version]
  OPTIONAL = [:author, :email, :homepage, :rubyforge_project]
  ALL = REQUIRED+OPTIONAL
  REPLACE = {:rubyforge_project => "RubyForge project"}
  def initialize
    @settings = {}
    @bin = Dir["bin/**/*"]
    @lib = Dir["lib/**/*"]
    @all = @bin + @lib
    
    if @all.empty?
      puts "Can't find anything to make a gem out of..."
      exit
    end
    
    if File.exists? ".gemified"
      @settings = YAML.load(open(".gemified"))
    end
  end
  
  def main
    loop do
      menu
      puts @result if @result
      result = nil
      l=(i=gets).downcase[0]
      i=i.to_i
      
      if l==?x
        puts "Exiting..."
        exit
      end   
      
      if l==?b
        build
      end
      
      if (1..ALL.length).include? i
        sub_task(i)
        next
      end
      
      if i==ALL.length+1
        save
        next
      end
      
      if i==ALL.length+2
        @result = @all.join($/)
        next
      end
      @result = "Can't find task..."
    end
  end
  
  def menu
    clear
    puts "Welcome to Gemify!"
    puts
    puts "Which task would you like to invoke?"
    ALL.each do |m|
      puts build_task(m)
    end
    puts "#{ALL.length+1}) Save"
    puts "#{ALL.length+2}) Show included files"
    puts
    puts "b) Build gem"
    puts "x) Exit"
    puts
  end
  
  def build
    Gem::Builder.new(Gem::Specification.new do |s|
      @settings.each do |key, value|
        s.send("#{key}=",value)
      end
      s.platform = Gem::Platform::RUBY
      s.files = @all
      s.bindir = "bin"
      s.require_path "lib"

      unless @bin.empty?
        s.executables << @bin.map{|x|x[4..-1]}
      end
    end).build
    exit
  end
  
  def save
    File.open(".gemified","w") do |f|
      f << YAML.dump(@settings)
    end
    @result = "Saved!"
  end
  
  # Tasks
  def build_task(m)
    index = (ALL.index(m)||0)+1
    verb,now = if @settings.keys.include?(m)
      ["Change"," = " + @settings[m]]
    else
      ["Set"," "]
    end
    req = REQUIRED.include?(m) ? " (required)" : ""
    "#{index}) #{verb} #{show(m)}#{req}#{now}"
  end
  
  def sub_task(i)
    key = ALL[i-1]
    menu
    @settings[key] = gets(key)
    @result = "Updated '#{show(key)}'"
  end
  
  # Helpers
  def clear
    print "\e[H\e[2J"
  end
  
  def gets(m=nil)
    print m ? "> #{show(m).capitalize}: " : "> "
    $stdin.gets.strip
  end
  
  def show(m)
    REPLACE[m]||m.to_s
  end
end