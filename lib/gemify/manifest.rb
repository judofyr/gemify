module Gemify
  # A simple module to figure out which files that should be included in the
  # gem.
  #
  # == Using
  # #auto:: Automatically find the files.
  # #file, #vcs or #basic:: Find the files the specific place.
  module Manifest
    FILES = ["MANIFEST", "Manifest.txt", ".manifest"]
    class << self
      
      # Returns the first of #file, #vcs and #basic which returns a non-empty list.
      def auto
        v = file
        return v unless v.empty?
        v = vcs
        return v unless v.empty?
        basic
      end
      
      # Looks for the manifest in MANIFEST, Manifest.txt and .manifest,
      # separated by newline.
      def file
        if m = FILES.detect{ |x| File.exist?(x) }
          File.read(m).split(/\r?\n/)
        else
          []
        end 
      end
      
      # Determine which VCS you're using and returns all the files which are
      # under revision control.
      #
      # Set +forced_vcs+ to a single VCS to look for files in that specific VCS.
      def vcs(forced_vcs = false)
        case (forced_vcs || determine_vcs)
        when :git
          get_files_from_command("git-ls-files").delete_if { |w| w == ".gitignore" or w == ".gitattributes" }
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
        else
          []
        end
      end
      
      # Returns the most basic manifest: All files in lib/ and bin/
      def basic
        Dir["bin/*"] + Dir["lib/**/**"]
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