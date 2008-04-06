# DEPRECATED: Just here so we can easily merge it to the new source

require 'open3'

class Gemify

class VCS
  def self.determine_vcs
    vcs = :unknown
    if File.exist?(".git")
      vcs = :git
    elsif File.exist?("_darcs")
      vcs = :darcs
    elsif File.exist?(".hg")
      vcs = :hg
    elsif File.exist?(".bzr")
      vcs = :bzr
    elsif File.exist?(".svn")
      vcs = :svn
    elsif File.exist?("CVSROOT")
      vcs = :cvs
    end
    
    vcs
  end
  
  def self.get_files_from_command(command)
    files = []
    
    Open3.popen3(command) do |stdin, stdout, stderr|
      stdout.each { |line|
        file = line.strip
        files << file if File.exist?(file)
      }
    end
    files
  end
  
  def self.files(forced_vcs = false)
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
end

end
