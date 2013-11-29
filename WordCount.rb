#!/usr/bin/ruby
# coding: utf-8

require 'socket'

class WordCount
  def initialize(data, wordcount_criteria)
    # data must be a hash of which keys are exp_id and values are design_description
    # wordcount_criteria must be an array of numbers without starting zero
    @socket = TCPSocket.open("localhost", 7070)
    @data = data
    @wordcount_criteria = wordcount_criteria
    raise NameError if wordcount_criteria.first == 0
  end
  
  def run_process
    word_counted = wordcount
    grouped_data = group_by_criteria(word_counted)
    
    run_genia
    word_freq = grouped_data.map do |words_array|
      get_words_freq(words_array)
    end
  end
  
  def count_words
    # remove items with no description, return array of description and wordcount
    words_with_num = @data.map do |id, description|
      num_of_words = wordcounter(description)
      [id, description, num_of_words] if num_of_words != 0
    end
    words_with_num.compact
  end
  
  def wordcounter(description)
    description.split(/\s+/).size
  end
  
  def group_by_criteria(word_counted)
    # items grouped by num_of_words and return an array of non-redundant description
    @wordcount_criteria.map.with_index do |upper_limit, index|
      lower_limit = index == 0 ? 0 : @wordcount_criteria[index - 1]
      members = word_counted.select do |array|
        size = array[2]
        lower_limit < size && size =< upper_limit
      end
      members.map{|array| select_distinct(array[1]) }
    end
  end
  
  def no_description
    @data.select{|id, description| wordcounter(description) == 0 }
  end
  
  def run_genia
    pid = fork #子プロセス実体化
    if !pid #子プロセスで処理
      system("ruby ../GENIA_server/GENIA_server.rb")      
      exit!(0) #子プロセス終了
    end
  end
  
  def get_words_freq
    word_freq = grouped_data.map do |words_array|
      get_words_freq(words_array)
    end
  end
end

if __FILE__ == $0
  dummy_hash = Hash.new #{id番号, 文章}...
  dummy_borders = [20, 40, 60];
  
  word_count = WordCount.new(dummy_hash, dummy_borders)
end
