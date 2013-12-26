# coding: utf-8

class GENIA_controller
  def initialize(genia_path)
    @genia = IO.popen("cd "+ genia_path +" ; ./geniatagger 2>/dev/null", "r+")
  end
  
  def tagger_sentence(sentence) #英文を受取り、品詞解析結果を返す
    line_num  = 1+sentence.scan("\n").size #文の数を数える
    @genia.print sentence + "\n" #行末で改行してgeniaプロセスに投げ込む
    
    result = []
    while line = @genia.gets
      if line == "\n"
        line_num -=1 #残り行数を減らす
        break if line_num == 0
      else
        result << line
      end
    end

    return result.join
  end
end


#以下エントリーポイント
if __FILE__==$0
  sentence = "This is a pen! You can use it."
  genia = GENIA_controller.new("../GENIA_server")
  puts genia.tagger_sentence(sentence)
  puts genia.tagger_sentence("Additional sentence can be tagged.\n")
end
