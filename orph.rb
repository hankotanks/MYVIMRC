# frozen_string_literal: true

# Returns an array of ALL slip IDs
def find_all_ids
  Dir.glob('./*.txt').concat(Dir.glob('./*.adoc')) - ['./Orphans.txt']
end

def find_links(id)
  f = File.read(id)
  return [] unless /<{2}\d{8}\.\d{4}.*?(\.txt|\.adoc)>{2}/.match? f

  f.scan(/<{2}\d{8}\.\d{4}.*?>{2}/).map { |m| m.delete('<>') }
end

def find_all_links
  fl = []
  find_all_ids.each { |id| fl.concat find_links id }
  fl
end

def links?(id)
  f = File.read(id)
  /<{2}.*?>{2}/.match? f
end

def orphan?(id, all)
  !all.include?(id) and !links?(id)
end

l = find_all_links
f = File.new('./Orphans.txt', 'w')
f.write(".Orphans\n")
find_all_ids.sort.each do |id|
  f.write("* <<#{File.basename(id)}>>\n") if orphan?(File.basename(id), l)
end
f.close
