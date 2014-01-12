# -*- coding: utf-8 -*-

require "rspec"
require "./WordCount"

describe WordCount do
  before do
    hash = {}
    hash["1"] = "come up to meet you, tell you I'm sorry, you don't know how lovely you are"
    hash["2"] = "I had to find you, tell you I need you, tell you I set you apart"
    hash["3"] = "tell me your secrets, and ask me your questions, oh let's go back to the start"
    hash["4"] = "running in circles; coming up tails heads on a silence apart"
    border = [2, 5]
    @wc = WordCount.new("./geniatagger", hash, border)
    @sorted_by_wordcount = @wc.wordcounter
  end
  
  it "count words and return an array" do
    expect(@sorted_by_wordcount.first[0]).to eq("4")
    expect(@sorted_by_wordcount.last[0]).to eq("1")
  end
  
  it "returns an array of words sorted by freq in a sentence" do
    bag_of_words = @wc.original_hash["1"]
    words_freq = @wc.get_words_freq(bag_of_words)
    expect(words_freq.last[0]).to eq("you")
  end
end
