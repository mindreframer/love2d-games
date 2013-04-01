#!/usr/bin/env ruby

# redefining of fail for slightly more friendly messaging
def fail(msg, code = 1)
  STDERR.print "Error: #{msg}#{msg.end_with?("\n") ? '' : "\n"}"
  exit code
end

if ARGV.length < 2
  print "Usage: ruby love_builder.rb love_file_location love_location\n"
  print "Creates a merged executable. (for Windows). Make sure you are in the project folder when using this program.\n"
  print "\n"
  print "\tlove_file_location - The .love file to be used for this program. (with or without the extension)\n"
  print "\tlove_location - The location of the copy of the love.exe file.\n"
  exit 1
end

fail "Directory does not contain a main.lua file.\n" unless File.exists? 'main.lua'
fail "The location you specified for the .love file does not exist. (#{ARGV[1]})\n" unless File.exists? ARGV[1]
fail "The location you specified for the executable does not exist. (#{ARGV[2]})\n" unless File.exists? ARGV[2]
print "Merging...\n"

`copy /b #{ARGV[2]}+#{ARGV[1].end_with?('.love') ? ARGV[1] : ARGV[1] + '.love'} > temp.exe` # if we don't using a temp file, it seems to not run properly

if $?.exitstatus != 0
  File.delete 'temp.exe'
  fail "Merge was unsuccessful.\n"
end

File.rename('temp.exe', ARGV[2])
print "Merged executable created successfully.\n"