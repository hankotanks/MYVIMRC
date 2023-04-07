# frozen_string_literal: true

# Returns an array of ALL slip IDs
def find_all_ids
  Dir.glob('./*.txt').concat Dir.glob('./*.adoc')
end

# Returns a hash of IDs and their keywords
def self.find_tags(note_id)
  tags = Hash.new { |hsh, key| hsh[key] = [] }
  File.foreach(note_id) do |line|
    # break out of the method if we hit a blank line
    return tags if /^\s*$/.match?(line)

    if /^:keywords:.*$/.match? line
      /(?<=^:keywords:).*$/.match(line).to_s.split(/(?<=\w)[,\s]\s*/).map(&:strip).each { |t| tags[t] << note_id }
      return tags
    end
  end
end

def find_all_tags
  all_tags = Hash.new { |hsh, key| hsh[key] = [] }
  find_all_ids.each do |id|
    find_tags(id)&.each { |tag, note| all_tags[tag].push note.pop }
  end
  all_tags.sort.to_h
end

def find_title(name)
  s = File.open(name, &:readline)
  s.chr == '=' ? (s[1..-1].strip.concat ' ') : ''
end

def register
  f = File.new('./Register.txt', 'w')
  f.write("= Register\n\n")
  find_all_tags.each do |tag, notes|
    f.write(".#{tag}\n")
    notes.each do |note|
      f.write("* #{find_title(note)}<<#{note.match(/\d{8}.\d{4}..{3,4}/)}>>")
      note == notes.last ? f.write("\n\n") : f.write("\n")
    end
  end
  f.close
end

register
