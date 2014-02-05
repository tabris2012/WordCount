# -*- coding: utf-8 -*-

class GENIAController
  def initialize(genia_path)
    @genia = IO.popen("cd #{genia_path} && ./geniatagger 2>/dev/null", "r+")
  end
  
  def tagger(sentence)
    @genia.print(sentence + "\n")
    array = []
    loop do
      line = @genia.gets
      break if line == "\n"
      array << line
    end
    array
  end
  
  def close
    @genia.close
  end
end

#以下エントリーポイント
if __FILE__==$0
  sentence = "This is a pen! You can use it."
  genia = GENIAController.new("../GENIA_server")
  puts genia.tagger_sentence(sentence)
  puts genia.tagger_sentence("Additional sentence can be tagged.\n")
end
