module Gemify
  class UI
    class CLI < self
       def main
        loop do
          menu
          @result = puts @result if @result
          l=(o=gets).downcase[0]
          i=o.to_i

          case l
          when ?x
            exit
          when ?b
            unless base.build! && exit
              @result = "You need to fill out all the required fields"
              next
            end
          when ?s
            save!
            next
          when ?i
            @result = "Included files:#{$/}" + base.files.join($/)
            next
          end

          if (1..Base::ALL.length).include? i
            change(Base::ALL[i - 1])
            next
          end

          @result = "Can't find the task named '#{o}'"
        end
      end

      def menu
        clear
        puts "Welcome to Gemify!"
        puts
        puts "Which task would you like to invoke?"
        Base::ALL.each do |m|
          puts build_task(m)
        end
        puts
        puts "s) Save"
        puts "i) Show included files"
        puts
        puts "b) Build gem"
        puts "x) Exit"
        puts
      end

      def build_task(m)
        index = Base::ALL.index(m) + 1
        unless base.type(m) == :boolean
          verb,now = if base.settings.keys.include?(m)
                       ["Change"," = " + base.show(m)]
                     else
                       ["Set",""]
                     end
        else
          verb, now = ["Toogle"," = " + base.show(m)]
        end
        req = Base::REQUIRED.include?(m) ? " (required)" : ""
        "#{index}) #{verb} #{base.name(m)}#{req}#{now}"
      end

      def change(m)
        menu
        case base.type(m)
        when :array
          puts "Split by ENTER and press ENTER twice when you're done"
          puts "> #{base.name(m).capitalize}: "
          base[m] = $stdin.gets($/*2).strip.split($/)
        when :boolean
          base[m] = !base[m]
        when :string
          print "> #{base.name(m).capitalize}: "
          base[m] = $stdin.gets.strip
        end
        @result = "Updated '#{m}'"
      end

      def gets
        print "> "
        $stdin.gets.strip
      end

      def clear
        system("cls") || print("\e[H\e[2J")
      end
    end
  end
end
