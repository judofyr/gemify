require 'rubygems'
require 'rubygems/builder'
require 'yaml'

class Gemify
  class Exit < StandardError;end
  REQUIRED = [:name, :summary, :version]
  OPTIONAL = [:author, :email, :homepage, :rubyforge_project, :dependencies]
  ALL = REQUIRED+OPTIONAL
  REPLACE = {:rubyforge_project => "RubyForge project"}
  def initialize
    @settings = {}
    @all = (@bin = Dir["bin/**/*"]) + Dir["lib/**/*"]
    
    if @all.empty?
      puts "Can't find anything to make a gem out of..."
      raise Exit
    end
    
    if File.exists? ".gemified"
      @settings = YAML.load(open(".gemified"))
    end
  rescue Errno::EACCES
    @result = "Can't read .gemified"
  end
  
  def main
    loop do
      menu
      puts @result if @result
      @result = nil
      l=(o=gets).downcase[0]
      i=o.to_i
      
      if l==?x
        puts "Exiting..."
        raise Exit
      end   
      
      if l==?b
        build
      end
      
      if (1..ALL.length-1).include? i
        sub_task(i)
        next
      end
      
      case i-(ALL.length-1)
      when 1
        puts "Write all your dependencies here, split by ENTER and"
        puts "press ENTER twice when you're done:"
        @dependencies = $stdin.gets($/*2).strip.split($/)
        @dependencies = nil if @dependencies.empty?
        @result = "Updated 'dependencies'"
        next
      when 2
        save
        next
      when 3
        @result = "Included files:#{$/}" + @all.join($/)
        next
      end
      
      @result = "Can't find the task named '#{o}'"
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
  
  ## Special tasks
  
  def build
    Gem::Builder.new(Gem::Specification.new do |s|
      @settings.each { |key, value| s.send("#{key}=",value) }
      s.platform = Gem::Platform::RUBY
      s.files = @all
      s.bindir = "bin"
      s.require_path = "lib"

      unless @bin.empty?
        s.executables = @bin.map{|x|x[4..-1]}
      end
      
      (@dependencies||[]).each do |dep|     
        s.add_dependency dep
      end
    end).build
    raise Exit
  end
  
  def save
    File.open(".gemified","w"){|f|f<<YAML.dump(@settings)}
    @result = "Saved!"
  rescue Errno::EACCES
    @result = "Can't write to .gemified"
  end  
  
  def sub_task(i)
    key = ALL[i-1]
    menu
    @settings[key] = gets(key)
    @settings.delete(key) if @settings[key].empty?
    @result = "Updated '#{show(key)}'"
  end
  
  # Helpers
  private
  def build_task(m)
    index = (ALL.index(m)||0)+1
    verb,now = if @settings.keys.include?(m)
      ["Change"," = " + inspect_setting(m)]
    else
      ["Set",""]
    end
    req = REQUIRED.include?(m) ? " (required)" : ""
    "#{index}) #{verb} #{show(m)}#{req}#{now}"
  end
  
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
  
  def inspect_setting(m)
    case i=@settings[m]
    when Array
      i.join(", ")
    else
      i.to_s
    end
  end
end