#!/usr/bin/ruby
# coding: utf-8
require 'webrick'

def readlines_until_empty_line(io, line_num) #geniaソケットから回収
  result = []
  while line = io.gets
    if line == "\n"
      line_num -=1 #残り行数を減らす
      break if line_num == 0
    else
      result << line
    end
  end
  result
end

genia = IO.popen("./geniatagger 2>/dev/null", "r+")

server = WEBrick::GenericServer.new(:Port => 7070)
trap(:INT) do
  server.shutdown
  genia.close
end
server.start do |socket|
  while line = socket.gets #一行読込む
    line_num  = 1+line.scan(". ").size
    genia.print line.gsub(". ", ".\n") #改行に変更してgeniaソケットに投げ込む
    socket.print readlines_until_empty_line(genia, line_num).join.gsub("\n", " "), "\n"
  end
end
