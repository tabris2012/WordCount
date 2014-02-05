# -*- coding: utf-8 -*-

require "./genia_controller"
require "json"

class WordCount
  def initialize(genia_path, description_hash, word_borders)
    @genia = GENIAController.new(genia_path)
    @original_hash = description_hash
    @set_borders = word_borders
  end
  attr_reader :original_hash
  
  def self.array_to_hash(array)
    hash = {}
    array.each do |id_desc|
      hash[id_desc[0]] = id_desc[1].gsub(/\s+/,"\s")
    end
    hash
  end
  
  def run_process
    # arrays of desc grouped by number of words
    desc_groups = desc_group_by_criteria
    
    # get an array of which values are word list with its usage frequency
    words_freq = desc_groups.map{|desc| get_words_freq(desc) }
    
    # save result in json format with filename of current time
    open(File.join(@target_dir,Time.now.to_s+".json"),"w"){|f| JSON.load(words_freq, f) }
    
    # close IO port
    @genia.close
  end
  
  def get_words_freq(bag_of_words)
    result = @genia.tagger(bag_of_words)
    hash = {}
    result.each do |line_t|
      line = line_t.split("\t")
      if line[2] =! /^NN/
        word = line[1].downcase
        hash[word] ||= 0
        hash[word] += 1
      end
    end
    hash.sort_by{|k,v| v }
  end
  
  def desc_group_by_criteria
    id_group_by_criteria.map do |range_member|
      desc = range_member.map{|id| @original_hash[id] }
      desc.flatten
    end
  end
  
  def id_group_by_criteria
    border_ranges.map do |range|
      members = wordcounter.select{|n| range.include?(n[1]) }
      members.map{|n| n.first }
    end
  end
  
  def border_ranges
    borders = [0] + @set_borders
    borders.map.with_index do |num, index|
      case index
      when borders.size - 1
        num..Float::INFINITY
      else
        num..borders[index+1]
      end
    end
  end
  
  def no_description
    members = wordcounter.select{|n| n[1] == 0 }
    members.map{|n| n.first }
  end
  
  def wordcounter
    hash = {}
    @original_hash.each_pair do |id, desc|
      words_size = desc.split(/\s+/).size
      hash[id] = words_size
    end
    hash.sort_by{|k,v| v }
  end
end

if __FILE__ == $0
  design_description = open("./result.json"){|f| JSON.load(f) }
  hash = WordCount.array_to_hash(design_description)
  borders = [20,50,100]
  wc = WordCount.new("./geniatagger", hash, borders)
  wc.run_process
end
