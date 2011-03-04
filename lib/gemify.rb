module Gemify
  extend self
  
  # Asks the user for a correct value of an attribute:
  # 
  #   >> input! "correct\n"
  #   >> ask("Hello", "world")
  #   => "correct"
  #   >> last_output
  #   => "Hello:               world? "
  # 
  # If the user just presses ENTER, use the provided value:
  # 
  #   >> input! "\n"
  #   >> ask("Hello", "world")
  #   => "world"
  #   >> last_output
  #   => "Hello:               world? "
  def ask(attribute, value)
    col = "#{attribute}:".ljust(20)
    print "#{col} #{value}? "
    new_value = $stdin.gets.chomp
    new_value.empty? ? value : new_value
  end
  
  # Asks a question which defaults to false.
  #
  #   >> input! "Y\n"
  #   >> yes("Well?")
  #   => true
  #   >> last_output
  #   => "[?] Well? (y/[N]) "
  # 
  #   >> input! "\n"
  #   >> yes("Well?")
  #   => false
  #   >> last_output
  #   => "[?] Well? (y/[N]) "
  def yes(question)
    print "[?] #{question} (y/[N]) "
    $stdin.gets[0,1].downcase == "y"
  end
  
  # 
  # 
  #   >> clean_name("Hello Æwesome!")
  #   => "Hellowesome"
  def clean_name(name)
    name.gsub(/[^a-zA-Z0-9_-]/, '')
  end
  
  # Converts a project name into a namespace:
  # 
  #   >> name_to_namespace('foo_bar-qux')
  #   => "FooBar::Qux"
  def name_to_namespace(name)
    name.gsub(/_?([a-zA-Z0-9]+)/) { $1.capitalize }.gsub('-', '::')
  end
  
  # Converts a namespace to a library name:
  # 
  #   >> namespace_to_library("FooBar::Qux")
  #   => "foo_bar/qux"
  #   >> namespace_to_library("HTTParty")
  #   => "httparty"
  def namespace_to_library(namespace)
    namespace.split("::").map do |part|
      part.scan(/([A-Z]+[a-z0-9]+)/).join('_').downcase
    end.join('/')
  end
  
  WARNINGS = {}
  
  def w(type, str)
    WARNINGS[type] = true
    puts "- #{str}"
  end
  
  def w?(type)
    WARNINGS[type]
  end
  
  def n(str)
    puts "[+] #{str}"
  end
end

