# -*- coding: utf-8 -*-

require "rspec"
require "./genia_controller"

describe GENIAController do
  before do
    path = "./geniatagger"
    @g = GENIAController.new(path)
  end
  
  it "tags each elements in a sentence" do
    sent = "This is a pen."
    t = @g.tagger(sent)
    first = t.first.split("\t")
    expect(first.size).to eq(5)
    expect(first.first).to eq("This")
  end
end
