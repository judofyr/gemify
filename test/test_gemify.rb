# Poor man's doctest with mocking of input/output.

require 'gemify'
require 'stringio'

$myinput = StringIO.new
$myoutput = StringIO.new
$myoutputpos = 0

code   = /^\s+#\s+>> (.*?)$/
result = /^\s+#\s+=> (.*?)$/
last_code = nil

passed = 0
failed = 0
tests = 0
lineno = 0

def run_code(str)
  $stdin = $myinput
  $stdout = $myoutput
  Gemify.instance_eval(str)
ensure
  $stdin = STDIN
  $stdout = STDOUT
end

def input!(s)
  $myinput << s
  $myinput.pos -= s.length
end

def last_output
  n = $myoutput.pos - $myoutputpos
  $myoutput.pos = $myoutputpos
  $myoutputpos += n
  $myoutput.read(n)
end

File.open(File.dirname(__FILE__) + '/../lib/gemify.rb') do |f|
  f.each do |line|
    lineno += 1
    
    case line
    when code
      last_code = run_code($1)
    when result
      last_result = run_code($1)
      tests += 1
      
      if last_result == last_code
        passed += 1
      else
        failed += 1
        puts
        puts "FAIL on Line #{lineno}:"
        puts "  Expected: #{last_result.inspect}"
        puts "  Actual:   #{last_code.inspect}"
      end
      
      last_code = true
    end
  end
end

puts "#{tests} tests, #{passed} passed, #{failed} failed"
exit failed.zero?
