require "delegate"
require "curses"

module Gemify
  class UI
    class Curses < self
      include ::Curses

      def main
        # init curses
        init_screen
        cbreak
        noecho
        nl
        # start the main window
        MAIN_WINDOW.start(base)
      end

      class MainWindow < DelegateClass(::Curses::Window)
        include ::Curses

        def initialize; super(stdscr); end

        def start(base)
          @banner = BannerWindow.new(stdscr)
          @display = DisplayWindow.new(stdscr)
          @tasks = TaskWindow.new(stdscr, base)
          @help = HelpWindow.new(stdscr)
          draw
          @tasks.start
        end

        def draw
          clear
          @banner.draw
          @display.draw
          @tasks.draw
          @help.draw
        end

        def message(msg)
          @display << msg
        end

        def input(msg)
          @display.input(msg)
        end

        def input_char(msg)
          @display.input_char(msg)
        end
      end

      MAIN_WINDOW = MainWindow.new

      class BannerWindow < DelegateClass(::Curses::Window)
        def initialize(window)
          super(window.subwin(4, window.maxx, 0, 0))
        end

        def draw
          clear
          standout
          self << "Welcome to Gemify!".center(maxx)
          standend
          setpos(2, 0)
          self << "Which task would you like to invoke?"
          refresh
        end
      end

      class DisplayWindow < DelegateClass(::Curses::Window)
        def initialize(window)
          super(window.subwin(1, window.maxx, window.maxy-1, 0))
        end

        def draw; clear; end

        def <<(msg)
          clear
          setpos(0, 0)
          addstr(msg.to_s.ljust(maxx))
          refresh
        end

        def input(msg)
          clear
          setpos(0, 0)
          addstr("> #{msg}: ")
          refresh
          ::Curses::echo
          res = getstr.strip
          ::Curses::noecho
          return res
        end

        def input_char(msg)
          clear
          setpos(0, 0)
          addstr("> #{msg}: ")
          refresh
          ::Curses::echo
          res = getch
          ::Curses::noecho
          return res
        end
      end

      class TaskWindow < DelegateClass(::Curses::Window)
        def initialize(window, base)
          super(window.subwin(window.maxy-8, window.maxx, 4, 0))
          @base = base
          @position = 0
          @tasks = Base::ALL
        end

        def draw
          clear
          @tasks.each_with_index do |task, idx|
            standout if @position == idx
            setpos(idx, 0)
            self << build_task(task).ljust(maxx)
            standend if @position == idx
          end
          refresh
        end

        def start
          keypad(true)
          loop do
            # handles input
            case c = getch
            when ?u, ::Curses::KEY_UP     ; up
            when ?d, ::Curses::KEY_DOWN   ; down
            when ?c, ::Curses::KEY_CTRL_J ; change
            when ?b; build
            when ?s; save
            when ?i; IncludedFiles.new(@base.files)
            when ?q; quit
            else
              @display << "[" + ::Curses.keyname(c).to_s + "]" if $DEBUG
            end

            # show message
            if @result
              MAIN_WINDOW.message(@result)
              @result = nil
            end

            # redraw
            draw
          end
        end

        def up
          @position -= 1 unless @position == 0
        end

        def down
          @position += 1 unless @position == @tasks.size - 1
        end

        def build
          unless @base.build!
            @result = "You need to fill out all the required fields"
          else
            gemname = "#{@base.show(:name)}-#{@base.show(:version)}.gem"
            @result = "Created " + gemname
          end
        end

        def save
          @changed = false
          save!
        end

        def quit
          if @changed
            res = ::Curses.keyname(MAIN_WINDOW.input_char(<<-__Q__.chomp))
Changes are not saved. Quit? (y or n)
            __Q__
            return unless res == "y" || res == "Y"
          end
          exit
        end

        def change
          task = @tasks[@position]
          case @base.type(task)
          when :array
            File.open("b","w"){|x|x<<@base.inspect}
            res = @display.input "#{@base.name(task).capitalize}(Split by SPACE)"
            @base[task] = res.strip.split(" ")
          when :boolean
            @base[task] = !@base[task]
          when :string
            @base[task] = MAIN_WINDOW.input @base.name(task).capitalize
          end
          @result = "Updated '#{@base.name(task)}'"
          @changed = true
        end

        def build_task(task)
          unless @base.type(task) == :boolean
            verb,now = if @base.settings.keys.include?(task)
                         ["Change"," = " + @base.show(task)]
                       else
                         ["Set",""]
                       end
          else
            verb, now = ["Toogle"," = " + @base.show(task)]
          end
          req =
            if Base::REQUIRED.include?(task) and @base.show(task).nil?
              " (required)"
            else "" end
          " * #{verb} #{@base.name(task)}#{req}#{now}"
        end
      end

      class HelpWindow < DelegateClass(::Curses::Window)
        def initialize(window)
          super(window.subwin(1, window.maxx, window.maxy-3, 0))
        end

        def draw
          clear
          setpos(0, 0)
          addstr "q) Quit, s) Save, i) Show included files, b) Build the gem"
          refresh
        end
      end

      class IncludedFiles < DelegateClass(::Curses::Window)
        def initialize(files)
          @files = files
          window = ::Curses.stdscr
          window.clear
          super(window.subwin(window.maxy, window.maxx, 0, 0))
          draw
          getch
          close
          MAIN_WINDOW.draw
        end

        def draw
          setpos(0, 0)
          standout
          addstr "Manifest(included files)".center(maxx)
          standend
          @files.each_with_index do |file, idx|
            setpos(idx+1, 0)
            addstr file
          end
          refresh
        end
      end

    end
  end
end
