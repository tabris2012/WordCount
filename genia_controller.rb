# -*- coding: utf-8 -*-

class GENIAController
  def initialize(genia_path)
    @genia = IO.popen("cd " + genia_path + " ; ./geniatagger 2>/dev/null", "r+")
  end
  
  def tagger_sentence(sentence)
    # count line number
    line_num  = 1 + sentence.scan("\n").size
    
    # 行末で改行してgeniaプロセスに投げ込む
    @genia.print sentence + "\n"
    
    result = []
    while line = @genia.gets
      puts line
      if line == "\n"
        line_num -=1 #残り行数を減らす
        break if line_num == 0
      else
        result << line
      end
    end

    result.join
  end
end


#以下エントリーポイント
if __FILE__==$0
  sentence = "This is a pen! You can use it."
  genia = GENIAController.new("../GENIA_server")
  puts genia.tagger_sentence(sentence)
  puts genia.tagger_sentence("Additional sentence can be tagged.\n")
end
