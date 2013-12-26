#!/usr/bin/ruby
# coding: utf-8
require 'fileutils'
require './GENIA_controller'

class WordCount
  def initialize(discription_hash, word_borders)
    @genia = GENIA_controller.new("../GENIA_server") #GENIAで品詞解析
    @original_hash = discription_hash
    @set_borders = word_borders
    
    run_process
  end
  
  def run_process
    sorted_id = sort_words #ハッシュの文章の単語数でソート
    words_arrays = divide_words(sorted_id) #文章の単語数を指定の境界で切る
    dump_id_discription(words_arrays) #単語数ごとに分割して出力
    puts "Sort by number of words done."

    words_arrays.each_with_index do |id_words, i|
      words_freq = get_words_freq(id_words)
      dump_words_freq(words_freq, i) #設定境界で単語数出力
    end
    puts "Word frequency has calculated."
  end
  
  def dump_words_freq(words_freq, index)
    filename = ""
    save_dir = "./words_freq"
    
    if !File.exist?(save_dir) #フォルダが存在しなかったら作成
      Dir.mkdir(save_dir)
    end
    
    if index < @set_borders.length
      filename = @set_borders[index].to_s + "_words_and_under_freq.txt"
    else
      filename = "over_" + @set_borders[-1].to_s + "_words_freq.txt"
    end
    
    output = open(save_dir+"/"+filename, "w") #出力ファイル展開
    
    words_freq.each do |word, freq|
      output.write(word + "\t" + freq.to_s + "\n")
    end
      
    output.close
  end
  
  def get_words_freq(id_words) #文章からの単語リストを作成
    word_list = Hash.new #出現単語数を数えるハッシュ
    
    id_words.each do |id, num|
      puts @original_hash[id]
      result = @genia.tagger_sentence(@original_hash[id]).chomp
      
      result.each_line do |line|
        elements = line.split(/\t/) #タブ区切り
        
        if elements[2] =~ /^NN/ #名詞を回収
          word = elements[1].downcase #小文字に直す
          
          if word_list.include?(word) #既に追加済なら
            word_list[word] += 1
          else #新規登録
            word_list[word] = 1
          end
        end
      end
    end
    #出現回数が多い順に並び替え
    return word_list.sort{|a,b| b[1] <=> a[1]}
  end
  
  def dump_id_discription(words_arrays)
    save_dir = "./words_divided"
    
    if !File.exist?(save_dir) #フォルダが存在しなかったら作成
      Dir.mkdir(save_dir)
    end
    
    @set_borders.each_with_index do |border, i|
      filename = border.to_s + "_words_and_under.txt"
      output = open(save_dir+"/"+filename, "w") #出力ファイル展開
    
      words_arrays[i].each do |id, num|
        output.write(id)
        output.write("\t")
        output.write(@original_hash[id])
        output.write("\n")
      end
      
      output.close
    end
    
    filename = "over_" + @set_borders[-1].to_s + "_words.txt"
    output = open(save_dir+"/"+filename, "w") #出力ファイル展開
    
    words_arrays[-1].each do |id, num|
      output.write(id)
      output.write("\t")
      output.write(@original_hash[id])
      output.write("\n")
    end
  end
  
  def divide_words(sorted_id) #id-単語数リストを分割
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
    end
    #最後を追加
    words_arrays.push(sorted_id.slice(last_border..-1))
    return words_arrays
  end
  
  def sort_words #オブジェクトのハッシュから文章単語数を回収
    words_hash = Hash.new #単語数保存用のハッシュを作成
    
    @original_hash.each do |id, discription|
      words = discription.split(/\s+/).length #スペースで区切って単語数
      words_hash[id] = words
    end
    
    word_list = words_hash.sort{|a,b| a[1] <=> b[1]}
    words0_pos = 0 #単語数が0より多くなるArray座標
    
    word_list.each_with_index do |(id, words), i|
      if words > 0 #単語数0より大きくなったら
        words0_pos = i
        break
      end
    end
    #idと単語数のハッシュを返す
    word_list = word_list.slice(words0_pos..-1)
  end
end

#以下エントリーポイント
if __FILE__==$0
  dummy_hash = Hash.new #{id, sentence}
  dummy_hash["10"]="This is a pen."
  dummy_hash["20"]="Have you been in Kobe last week?"
  dummy_hash["30"]="Hello, world!"
  dummy_hash["40"]="You have a pen."
  dummy_borders = [2, 5]
  
  word_count = WordCount.new(dummy_hash, dummy_borders)
end
