# -*- coding: utf-8 -*-

require "nokogiri"
require "parallel"
require "json"

def get_all_exp(target_dir)
  Dir.glob(target_dir+"/*RA*/*.experiment.xml")
end

def parse_design(xml_path)
  nkgr = Nokogiri::XML(open(xml_path))
  exp_array = nkgr.css("EXPERIMENT")
  exp_array.map do |exp|
    id = exp.attr("accession").to_s
    design_text = exp.css("DESIGN_DESCRIPTION").inner_text
    design = design_text.gsub("\n","").gsub(/\s+/,"\s")
    [id, design]
  end
end

if __FILE__ == $0
  list_xml_path = get_all_exp("./NCBI_SRA_Metadata_Full_20130801")
  id_desc = Parallel.map(list_xml_path, :in_threads => 12) do |xml_path|
    parse_design(xml_path)
  end
  open("./result.json","w"){|f| JSON.dump(id_desc.flatten(1), f) }
end
