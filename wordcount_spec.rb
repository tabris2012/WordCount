# -*- coding: utf-8 -*-

require "rspec"
require "./WordCount"

describe WordCount do
  before do
    data = open("./data/test.json"){|f| JSON.load(f) }
    criteria = [20,40]
    @wc = WordCount.new(data, criteria)
  end
  
  it "count words and return an array" do
    primary = @wc.count_words.first
    expect(primary[0]).to eq("DRX000001")
  end
  
  it "run genia and return freq of words" do
  end
end
