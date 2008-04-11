module Gemify
  # A class providing base functions for generating gems. It doesn't know
  # anything about the filesystem nor using any magic; you have to give it
  # all the information.
  #
  # == Using
  #
  #   base = Gemify::Base.new(["lib/file.rb", "bin/program"])
  #   base.settings = {:name => "testing"}
  #   base[:version] = 0.9
  #   base.valid? #=> false
  #   base[:summary] = "A short summary"
  #   base.valid? #=> true
  #
  #   base.build! # Builds the gem
  class Base
    attr_accessor :files
    attr_reader :settings
    
    REQUIRED = [:name, :summary, :version]
    OPTIONAL = [:author, :email, :homepage, :rubyforge_project, :has_rdoc, :dependencies]
    ALL = REQUIRED+OPTIONAL
    REPLACE = {
      :rubyforge_project => "RubyForge project",
      :has_rdoc => "documentation",
    }
    TYPE = {
      :has_rdoc => :boolean,
      :dependencies => :array,
    }
    
    def initialize(files)
      @files = files
      @settings = {}
    end
    
    def settings=(hash)
      @settings = hash
      ensure_settings!
    end
    
    # Returns the content of +setting+
    def [](setting)
      settings[setting]
    end
    
    # Sets the +setting+ to +value+
    def []=(setting, value)
      if v = cast(setting, value)
        settings[setting] = v
      else
        settings.delete(setting)
      end
    end
    
    # Returns all the binaries in the file list
    def binaries
      files.select { |file| file =~ /^bin\/[^\/]+$/ }
    end
    
    # Returns all the extensions in the file list
    def extensions
      files.select { |file| file =~ /extconf\.rb$/ }
    end
    
    # Checks if all the required field are set
    def valid?
      REQUIRED.each do |req|
        return false unless settings.keys.include?(req)
      end
      true
    end
    
    # Returns the type of a setting, defaults to :string 
    #
    #   type(:has_rdoc)         #=> :boolean
    #   type(:version)          #=> :string
    #   type(:dependecies)      #=> :array
    def type(setting)
      TYPE[setting] || :string
    end
    
    # Returns the name of a setting.
    #
    #   name(:has_rdoc)          #=> "documentation"
    #   name(:name)              #=> "name"
    #   name(:rubyforge_project) #=> "RubyForge project"
    def name(setting)
      REPLACE[setting] || setting.to_s
    end
    
    # Casts +value+ to the right type according to +setting+
    #
    # Returns nil if +value+ is empty, false or nil.
    #
    #   cast(:has_rdoc, "VICTORY!")      #=> true
    #   cast(:dependencies, "merb-core") #=> ["merb-core"]
    #   cast(:version, 0.2)              #=> "0.2"
    #
    #   cast(:name, "")                  #=> nil
    #   cast(:has_rdoc, false)           #=> nil
    #   cast(:dependencies, [])          #=> nil
    def cast(setting, value)
      return nil unless ALL.include?(setting)
      case type(setting)
      when :array
        i = value.to_a
        i unless i.empty?
      when :string
        i = value.to_s
        i unless i.empty?
      when :boolean
        true if !!value
      end
    end
    
    # Shows the content of +setting+ as a String.
    #
    #   show(:has_rdoc)     #=> "true"
    #   show(:version)      #=> "0.9"
    #   show(:dependencies) #=> "rubygems, merb-core" 
    #   show(:author)       #=> nil
    def show(setting)
      i = settings[setting]
      case type(setting)
      when :array
        i.join(", ")
      when :boolean
        (!!i).to_s
      when :string
        i
      end
    end
    
    # Creates a Gem::Specification+ based on +@files+ and +@settings+  
    def specification
      ensure_settings!
      se = settings.clone
      Gem::Specification.new do |s|
        (se.delete(:dependencies)||[]).each do |dep|
          s.add_dependency(dep)
        end

        se.each { |key, value| s.send("#{key}=",value) }
        s.platform = Gem::Platform::RUBY
        s.files = files
        s.bindir = "bin"
        s.require_path = "lib"

        unless binaries.empty?
          s.executables = binaries.map{|x|x[4..-1]}
        end

        unless extensions.empty?
          s.extensions = extensions
        end
      end
    end
    
    # Builds the gem if it's valid
    def build!
      # We need to load the specification before valid?
      # in order to ensure_settings!
      spec = specification
      valid? && Gem::Builder.new(spec).build
    end
    
    # Ensures that all settings are properly cast.
    def ensure_settings!
      settings.each do |key, value|
        self[key] = value
      end
    end                  
  end
end