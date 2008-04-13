module Gemify
  class UI
    class EmptyManifest < StandardError; end

    def self.use(name)
      case name.to_s
      when "cli"
        require "gemify/ui/cli"
        return Gemify::UI::CLI
      when "curses"
        require "gemify/ui/curses"
        return Gemify::UI::Curses
      else
        raise ArgumentError
      end
    end
  end

end
