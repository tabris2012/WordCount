#!/usr/bin/ruby
# coding: utf-8
require 'socket'

class WordCount
  def initialize(discription_hash, word_borders)
    @socket = TCPSocket.open("localhost", 7070) #GENIA通信用ソケット
    @original_hash = discription_hash
    @set_borders = word_borders
    
    run_process
  end
  
  def run_process
    sorted_id = sort_words #ハッシュの文章の単語数でソート
    words_arrays = divide_words(sorted_id) #文章の単語数を指定の境界で切る
    dump_id_discription(words_arrays) #単語数ごとに分割して出力
    run_genia #外部GENIA起動
    
    words_arrays.each_with_index do |id_words, i|
      words_freq = getWordsFreq(id_words)
      dumpWordsFreq(words_freq, @set_borders[i]) #設定境界で単語数出力
    end
  end
  
  
  
  def divide_words(sorted_id)
    words_arrays = Array.new
    border_pos = 0 #境界配列の現在参照
    last_border = 0 #前回の境界位置
    
    sorted_id.each_with_index do |(id, words), i|
      if words > @set_borders[border_pos]
        words_arrays.push(sorted_id.slice(last_border...i))
        border_pos +=1
        last_border = i #境界位置記憶
        
        if border_pos > @set_borders.length
          break #サイズを超えたら終了
        end
      end
      #最後を追加
      words_arrays.push(sorted_id.slice(last_border..-1))
      return word_borders
    end
    
  end
  
  def sort_words #ハッシュの文章単語数を回収
    words_hash = Hash.new #単語数保存用のハッシュを作成
    
    @original_hash.each do |id, discription|
      words = discription.split(/\s+/).length #スペースで区切って単語数
      words_hash[id] = words
    end
    
    word_list = words_hash.sort{|a,b| a[1] <=> b[1]}
    
    word_list.each_with_index do |(id, words), i|
      if words > 0 #単語数0より大きくなったら
        break
      end
    end
    
    word_list = word_list.slice(i..-1)
  end
  
  def run_genia #子プロセスでGENIA起動
    pid = fork #子プロセス実体化
    
    if pid.nil? #子プロセスで処理
      system("ruby ../GENIA_server/GENIA_server.rb")      
      exit!(0) #子プロセス終了
    end
  end
  
end

#以下エントリーポイント
if __FILE__==$0
  dummy_hash = Hash.new #{id番号, 文章}...
  dummy_borders = [20, 40, 60];
  
  word_count = WordCount.new(dummy_hash, dummy_borders)
end
