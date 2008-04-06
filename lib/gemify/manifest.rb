module Gemify
  module Manifest
    FILES = ["MANIFEST", "Manifest.txt", ".manifest"]
    class << self
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
      
      def from_vcs(forced_vcs = false)
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
        when :unknown
          Dir['bin/*'] + Dir['lib/**/**']    
        end
      end
      
      def from_file(filename)
        File.read(filename).split(/\r?\n/)        
      end
      
      def basic
        from_vcs(:unknown)
      end
      
      def manifest_file
        if m = FILES.detect{ |x| File.exist?(x) }
          from_file(m)
        end 
      end
      
      def auto
        if    manifest_file
        else  from_vcs
        end
      end
    end
  end
end