#! /usr/bin/env nix-shell
#! nix-shell -i ruby -p ruby -p rubyPackages.listen

# Script by kuon, from https://github.com/godotengine/godot/issues/10946#issuecomment-390451190 

require 'socket'
require 'listen'

cmd = "\x20\x00\x00\x00\x13\x00\x00\x00\x01\x00\x00\x00\x04\x00\x00\x00\x0e\x00\x00\x00reload_scripts\x00\x00"

server = TCPServer.open 6008

puts "Listening on port 6008"

loop do
  client = server.accept
  listener = Listen.to('demo') do |modified|
    if modified
      puts "File modified: #{modified}"
      client.write(cmd)
    end
  end
  listener.start
  # Read content to avoid using kernel memory
  while line = client.recv(1024)
    next if line.length < 10
    # Debug data packets
    #puts "###"
    #puts line.each_byte.map { |b| b.to_s(16).rjust(2, '0') }.join(':')
  end
end
