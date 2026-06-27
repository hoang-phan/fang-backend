require "yaml"
require "fileutils"

SEEDS_DIR = File.expand_path(".", __dir__)
CONV_DIR  = File.join(SEEDS_DIR, "conversations")

FileUtils.mkdir_p(CONV_DIR)

def slugify(str)
  str.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
end

opponents_data = YAML.load_file(File.join(SEEDS_DIR, "opponents.yml"))
written = []

opponents_data.each do |opp|
  opp_id = opp["id"]

  (opp["cinematics"] || []).each do |c|
    next unless c["conversations"].is_a?(Array)
    filename = "#{opp_id}-cinematic-#{c["level"]}.yml"
    File.write(File.join(CONV_DIR, filename), c["conversations"].to_yaml)
    c["conversations"] = filename
    written << filename
  end

  (opp["gifts"] || []).each do |g|
    next unless g["conversations"].is_a?(Array)
    filename = "#{opp_id}-gift-#{slugify(g["name"])}.yml"
    File.write(File.join(CONV_DIR, filename), g["conversations"].to_yaml)
    g["conversations"] = filename
    written << filename
  end

  next unless opp["conversations"].is_a?(Array)
  filename = "#{opp_id}-conversations.yml"
  File.write(File.join(CONV_DIR, filename), opp["conversations"].to_yaml)
  opp["conversations"] = filename
  written << filename
end

output_path = File.join(SEEDS_DIR, "opponents.yml.new")
File.write(output_path, opponents_data.to_yaml)

puts "Extracted #{written.size} conversation files to db/seeds/conversations/:"
written.each { |f| puts "  #{f}" }
puts "\nProposed new opponents.yml written to: db/seeds/opponents.yml.new"
puts "Review with: diff db/seeds/opponents.yml db/seeds/opponents.yml.new"
puts "Promote with: cp db/seeds/opponents.yml.new db/seeds/opponents.yml"
