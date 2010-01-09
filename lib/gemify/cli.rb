require 'readline'

Readline.completion_append_character = ""
Readline.completion_proc = proc do |str|
  Dir[str+'*'].grep /^#{Regexp.escape(str)}/
end

module Gemify
  class CLI
    ACTIONS = {
      ?x => :exit, ?s => :save, ?r => :reload, ?m => :rename, ?l => :list
    }
    
    attr_accessor :base, :file
    
    def initialize(base, file = nil)
      @base = base
      @base.mark_version
      @file = file
      @saved = !!file
    end
    
    def self.load(file = nil)
      case file
      when nil
        new(Base.new { |s| s.manifest = "auto" })
      when String
        new(Base.load(file), file)
      when Array
        file.each_with_index do |f, index|
          puts "#{index + 1}) #{f}"
        end
        puts
        print "> "
        chosen = file[gets.strip.to_i - 1]
        
        if chosen.nil?
          puts "Err. Sure you wrote the right number?"
          exit
        end
        
        load(chosen)
      end
    end
    
    def menu
      clear
      puts "Currently editing #{file || "<unnamed>"}#{' - not saved' if !@saved && @file }"
      puts
      puts "Which task would you like to invoke?"
      index = 0
      Base::ALL.each do |m|
        print "#{index += 1}) "
        print base[m].nil? ? "Set " : "Change "
        print m
        print " (required)" if Base::REQUIRED.include?(m)
        print " = #{base[m]}" unless base[m].nil?
        puts
      end
      puts
      puts "s) Save"
      puts "r) Reload (discard unsaved changes)"
      puts "m) Rename"
      puts "l) List files"
      puts
      puts "x) Exit"
      puts
    end
    
    def main
      @result = nil
      loop do
        menu

        if @result
          puts @result
          @result = nil
        end

        letter = (choice = gets).downcase[0]
        int = choice.to_i
        
        if action = ACTIONS[letter]
          send(action)
          next
        end

        if (1..Base::ALL.length).include? int
          change(Base::ALL[int - 1])
          next
        end

        @result = "Can't find the task named '#{choice}'"
      end
    end
    
    def change(m)
      base[m] = gets(m.to_s.capitalize)
      @saved = false
      @result = "Updated '#{m}'"
    rescue ArgumentError => e
      @result = "Error: #{e}"
    end
    
    def reload
      @base = Base.load(file)
      @result = "Reloaded #{file}"
    end
    
    def save
      @result = "Gemspec is invalid. Can't save." and return unless base.valid?
      @file ||= "#{@base.name}.gemspec"
      
      File.open(file, 'w') do |f|
        f << base.to_ruby
        @saved = true
      end
      
      @result = "#{file} saved!"
    end
    
    def rename
      @result = "Gemspec is invalid. Can't rename." and return unless base.valid?
      save
      old_name = @file
      default = @base.name + '.gemspec'
      @file = gets("[#{default}]")
      @file = default if @file.empty?
      File.rename(old_name, @file)
      @result = "Renamed #{old_name} to #{@file}"
    end
    
    def list
      puts @base.inspect_files
      gets "Ok? ", nil
    end
    
    def gets(thing = nil, post = ": ")
      prompt = thing ? "> #{thing}#{post}" : "> "
      Readline.readline(prompt, true)
    end
    
    def clear
      system("cls") || print("\ec")
    end
  end
end