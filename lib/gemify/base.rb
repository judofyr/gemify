module Gemify
  # A class providing base functions for generating gems. It doesn't know
  # anything about the filesystem nor using any magic; you have to give it
  # all the information.
  #
  # == Using
  #
  #   base = Gemify::Base.new(["lib/file.rb", "bin/program"])
  #   base[:version] = 0.9
  #   base.valid? #=> false
  #   base[:summary] = "A short summary"
  #   base.valid? #=> true
  #
  #   base.build! # Builds the gem
  class Base < Gem::Specification
    REQUIRED = [:name, :summary, :version]
    OPTIONAL = [:author, :email, :homepage, :dependencies]
    ALL = REQUIRED + OPTIONAL
    
    def manifest=(type)
      # do nothing
    end
    
    def inspect_files
      files.empty? ? "(no files)" : @files.join($/)
    end
    
    def version=(version)
      @version = version && super
    end
    
    # Returns the content of +setting+
    def [](setting)
      val = send(setting) if respond_to?(setting)
      if setting.to_s == "dependencies"
        val.empty? ? nil : val.map do |dep|
          "#{dep.name} #{dep.requirement}"
        end.join(" & ")
      else
        val
      end
    end
    
    # Sets the +setting+ to +value+
    def []=(setting, value)
      value = nil if value.is_a?(String) && value.empty?
      
      if setting.to_s == "dependencies"
        self.dependencies = []
        value.each do |dep|
          name, *reqs = dep.split(",").map { |x| x.strip }
          add_runtime_dependency(name, *reqs)
        end
      else
        send("#{setting}=", value) if respond_to?("#{setting}=")
      end
    end
    
    def valid?
      validate
    rescue Gem::InvalidSpecificationException
      false
    else
      true
    end
  end
end