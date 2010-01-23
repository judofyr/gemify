# Author: David A. Cuadrado
module Gemify
  # A simple module to figure out which files that should be included in the
  # gem.
  #
  # == Using
  # {.files}:: Find the files based on the argument.
  # {.auto}:: Automatically find the files.
  # {.vcs}, {.basic} or {.all}:: Find the files the specific place.
  module Manifest
    MODE  = [:auto, :vcs, :basic, :all]
    VCS   = [:git, :darcs, :hg, :bzr, :svn, :cvs]
    ALL   = MODE + VCS
    
    class << self
      
      def files(type)
        return unless type.respond_to?(:to_sym)
        type = type.to_sym
        case type
        when *VCS
          vcs(type)
        when *MODE
          send(type)
        else
          file = type.to_s
          if File.exists?(file)
            File.read(file).split($/).compact.uniq
          else
            raise ArgumentError, "#{type} is not a valid manifest"
          end
        end
      end
      
      # Uses the files from your VCS, falling back to all the files in
      # the directory. 
      def auto
        vcs || all
      end
      
      # Determine which VCS you're using and returns all the files which are
      # under revision control.
      #
      # Set +forced_vcs+ to a single VCS to look for files in that specific VCS.
      def vcs(forced_vcs = determine_vcs)
        case forced_vcs
        when :git
          get_files_from_command("git ls-files").delete_if { |w| w == ".gitignore" or w == ".gitattributes" }
        when :darcs
          get_files_from_command("darcs query manifest")
        when :bzr
          get_files_from_command("bzr ls").delete_if { |w| w == ".bzrignore" }
        when :hg
          get_files_from_command("hg manifest")
        when :svn
          get_files_from_command("svn ls")
        when :cvs
          get_files_from_command("cvs ls")
        end
      end
      
      # Returns the most basic manifest: All files in lib/ and bin/
      def basic
        Dir["bin/*"] + Dir["lib/**/**"]
      end
      
      # Returns all the files in a directory.
      def all
        Dir["**/*"]
      end
      
      private
      
      def determine_vcs
        if File.exist?(".git")
          :git
        elsif File.exist?("_darcs")
          :darcs
        elsif File.exist?(".hg")
          :hg
        elsif File.exist?(".bzr")
          :bzr
        elsif File.exist?(".svn")
          :svn
        elsif File.exist?("CVSROOT")
          :cvs
        else
          :unknown
        end
      end
      
      def get_files_from_command(command)
        files = []

        Open3.popen3(command) do |stdin, stdout, stderr|
          stdout.each { |line|
            file = line.strip
            files << file if File.exist?(file)
          }
        end
        
        files
      end
    end
  end
end