module Gemify
  class UI
    class EmptyManifest < StandardError; end

    SETTINGS = ".gemified"
    VCS = [:git, :darcs, :hg, :bzr, :svn, :cvs]
    MODE = [:auto, :file, :vcs, :basic]

    attr_reader :base

    def initialize(manifest = :auto)
      m = case manifest
          when *VCS
            Manifest.vcs(manifest)
          when *MODE
            Manifest.send(manifest)
          else
            []
          end

      raise EmptyManifest if m.empty?

      @base = Base.new(m)
      load!
    end

    def load!
      if File.exists?(SETTINGS)
        base.settings = YAML.load(File.read(SETTINGS))
      end
    rescue Errno::EACCES
      @result = "Can't read #{SETTINGS}"
    end

    def save!
      File.open(SETTINGS, "w"){ |f| f << YAML.dump(base.settings) }
      @result = "Saved the settings to #{SETTINGS}"
    rescue Errno::EACCES
      @result = "Can't write #{SETTINGS}"
    end 

    def self.use(name)
      case name.to_s
      when "cli"
        require "gemify/ui/cli"
        return Gemify::UI::CLI
      #when "curses"
      #  require "gemify/ui/curses"
      #  return Gemify::UI::Curses
      else
        raise ArgumentError, "There is no UI named '#{name}'"
      end
    end
  end

end
