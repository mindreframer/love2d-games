#!/usr/bin/env ruby

# for more friendly error messaging
def err(msg, code = 1)
  STDERR.puts "Error: #{msg}"
  exit code
end

def put(msg)
  STDOUT.puts msg
end

def archive(name)
  file = name
  file += '.love' unless file.end_with? '.love'
  put 'Archiving...'
  `zip -r #{file} *`

  if $?.exitstatus == 0
    put "#{name}.love created successfully."
  else
    err 'An error occurred file creating the file.'
  end
end

def merge
  err 'Please provide a executable location.' unless ARGV.length == 2
  err "The location you specified for the executable does not exist. (#{ARGV[1]})" unless File.exists? ARGV[1]
  archive('temp')
  put 'Merging...'

  if ARGV[1].end_with? '.app'
    name = File.basename(ARGV[1], '.app')
    `cat #{ARGV[1]}/Contents/MacOS/love temp.love > #{ARGV[1]}/Contents/MacOS/temp` # if we don't using a temp file, it seems to not run properly
    err 'Merge was unsuccessful.' if $?.exitstatus != 0
    File.rename("#{ARGV[1]}/Contents/MacOS/temp", "#{ARGV[1]}/Contents/MacOS/love")

    put 'Making file executable...'
    `chmod a+x #{ARGV[1]}/Contents/MacOS/love` # if we don't do this, it won't run properly (not executable)
  else
    `cat #{ARGV[1]} temp.love > temp`
    err 'Merge was unsuccessful.' if $?.exitstatus != 0
    File.rename('temp', ARGV[1])

    put 'Making file executable...'
    `chmod a+x #{ARGV[1]}`
  end

  err 'Merge was unsuccessful.' if $?.exitstatus != 0
  put 'Deleting temp.love...'
  File.delete('temp.love')
  put 'Merged executable created successfully.'
end

def new_project
  err "No project templates directory. (Should be located at '#{File.dirname(__FILE__)}/templates')" unless File.exists? "#{File.dirname(__FILE__)}/templates"
  
  if ARGV[2]
    dir = ARGV[2]
  else
    err 'Please specify a directory to create.' unless ARGV[1]
    err "No default project template. (Should be located at '#{File.dirname(__FILE__)}/templates/default')" unless File.exists? "#{File.dirname(__FILE__)}/templates/default"
    dir = 'default'
  end
  
  `cp -R #{File.dirname(__FILE__)}/templates/#{dir}/ #{ARGV[1]}`
  err 'Copying template was unsuccessful.' if $?.exitstatus != 0
  put 'Copied template successfully.'
end

if ARGV.length == 0
  put 'Usage: ./love_builder.rb [archive|merge]'
  put 'Make sure you are in the project folder when using this program.'
  put ''
  put 'archive:'
  put '\tUsage: ./love_builder.rb [archive] love_file_location'
  put '\tThis builds a .love file, and is the default command.'
  put ''
  put '\tlove_file_location - The location where you want the .love to be put. (Having a .love extension for this path is optional)'
  put ''
  put 'merge:'
  put '\tUsage ./love_builder.rb merge executable_location'
  put '\tThis creates a merged executable (on Mac this will be a .app file).'
  put ''
  put '\texecutable_location - The location of a copy of the love.app/love executable which can be used for your game. If you want to create Mac version you must end the path with the .app extension.'
  exit 1
end

if ARGV[0] == 'archive' or ARGV[0] !~ /merge|new/
  err 'Directory does not contain a main.lua file.' unless File.exists? 'main.lua'
  
  if ARGV[0] == 'archive' and ARGV[1]
    archive(ARGV[1])
  elsif ARGV[0]
    archive(ARGV[0])
  else
    put 'Please give a name for the .love file.'
    exit 1
  end
elsif ARGV[0] == 'merge'
  err 'Directory does not contain a main.lua file.' unless File.exists? 'main.lua'
  merge
elsif ARGV[0] == 'new'
  new_project
end