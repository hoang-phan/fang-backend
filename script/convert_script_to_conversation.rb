#!/usr/bin/env ruby
# Usage: ruby script/convert_script_to_conversation.rb <story_file.txt> [--id <opponent_id> --level <cinematic_level>]
#
# Without --id/--level: prints the chat blocks to stdout.
# With    --id/--level: appends a new conversation to that cinematic in opponents.yml.

require "optparse"

OPPONENTS_YML = File.expand_path("../db/seeds/opponents.yml", __dir__)

options = {}
parser = OptionParser.new do |opts|
  opts.on("--id ID", "Opponent id (e.g. illyasviel)")
  opts.on("--level N", Integer, "Cinematic level number")
end
parser.parse!(into: options)

story_file = ARGV[0]
abort "Usage: #{$0} <story_file.txt> [--id <id> --level <level>]" unless story_file
abort "File not found: #{story_file}" unless File.exist?(story_file)

if options[:id].nil? != options[:level].nil?
  abort "Both --id and --level must be provided together."
end

text = File.read(story_file)

# Split text into raw chunks on ".", "!", "?" or "\n", but:
#   - preserve "..." (three or more dots) as part of the current chunk
#   - do not split on "." / "!" / "?" that is inside double-quoted dialogue
def split_into_sentences(text)
  text = text.gsub("\r\n", "\n").strip

  sentences = []
  current = +""
  in_quotes = false
  i = 0

  while i < text.length
    ch = text[i]

    if ch == '"'
      in_quotes = !in_quotes
      current << ch
      i += 1
    elsif ch == "\n" && !in_quotes
      sentences << current.strip unless current.strip.empty?
      current = +""
      i += 1
    elsif ch == "." && text[i, 3] == "..."
      dots = ""
      while i < text.length && text[i] == "."
        dots << text[i]
        i += 1
      end
      current << dots
    elsif (ch == "." || ch == "!" || ch == "?") && !in_quotes
      current << ch
      sentences << current.strip unless current.strip.empty?
      current = +""
      i += 1
    else
      current << ch
      i += 1
    end
  end

  sentences << current.strip unless current.strip.empty?
  sentences
end

# From a sentence, extract ordered segments: dialogue and narrative.
def parse_segments(sentence)
  segments = []
  rest = sentence.dup

  while rest.length > 0
    open_idx = rest.index('"')

    if open_idx.nil?
      segments << { type: :narrative, content: rest.strip } unless rest.strip.empty?
      break
    end

    before = rest[0, open_idx].strip
    segments << { type: :narrative, content: before } unless before.empty?

    rest = rest[open_idx + 1..]
    close_idx = rest.index('"')

    if close_idx.nil?
      segments << { type: :dialogue, content: rest.strip } unless rest.strip.empty?
      break
    end

    dialogue = rest[0, close_idx].strip
    segments << { type: :dialogue, content: dialogue } unless dialogue.empty?
    rest = rest[close_idx + 1..]
  end

  segments
end

sentences = split_into_sentences(text)

blocks = []
sentences.each do |sentence|
  parse_segments(sentence).each do |seg|
    if seg[:type] == :dialogue
      blocks << { role: "hero", content: seg[:content] }
    else
      blocks << { role: "other", content: "(#{seg[:content]})" }
    end
  end
end

# Build indented chat lines (12-space indent to match opponents.yml)
def format_chat_lines(blocks, indent: "            ")
  lines = []
  blocks.each do |block|
    lines << "#{indent}- role: #{block[:role]}"
    lines << "#{indent}  content: #{block[:content]}"
  end
  lines
end

unless options[:id]
  puts format_chat_lines(blocks)
  exit
end

# --- Write mode: inject into opponents.yml ---

opponent_id = options[:id]
cinematic_level = options[:level]

yml_lines = File.readlines(OPPONENTS_YML, chomp: true)

# Find the opponent block by id
opponent_line = yml_lines.index { |l| l.match?(/^- id: #{Regexp.escape(opponent_id)}\s*$/) }
abort "Opponent '#{opponent_id}' not found in opponents.yml" if opponent_line.nil?

# Find the next top-level opponent (starts with "- id:") after our opponent, or EOF
next_opponent_line = yml_lines[(opponent_line + 1)..].index { |l| l.match?(/^- id:/) }
opponent_end = next_opponent_line ? (opponent_line + 1 + next_opponent_line) : yml_lines.length

opponent_block = yml_lines[opponent_line...opponent_end]

# Within the opponent block, find "  cinematics:" then the matching "  - level: N"
cinematics_offset = opponent_block.index { |l| l.match?(/^  cinematics:\s*$/) }
abort "No cinematics section found for opponent '#{opponent_id}'" if cinematics_offset.nil?

level_offset = opponent_block[(cinematics_offset + 1)..].index { |l| l.match?(/^    - level: #{cinematic_level}\s*$/) }
abort "Cinematic level #{cinematic_level} not found for opponent '#{opponent_id}'" if level_offset.nil?

level_abs = opponent_line + cinematics_offset + 1 + level_offset

# Find the "      conversations:" line within this level block
# The level block ends when we hit the next "    - level:" or end of opponent block
level_block_start = level_abs + 1
level_block_end = opponent_block[(level_abs - opponent_line + 1)..].index { |l| l.match?(/^    - level:/) }
level_block_end = level_block_end ? (opponent_line + level_abs - opponent_line + 1 + level_block_end) : opponent_end

conversations_offset = yml_lines[level_block_start...level_block_end].index { |l| l.match?(/^      conversations:\s*$/) }
abort "No conversations key found under cinematic level #{cinematic_level}" if conversations_offset.nil?

conversations_abs = level_block_start + conversations_offset

# Insert new conversation block after the conversations: key.
# A conversation entry starts with "        - chats:" (8 spaces).
new_conversation_lines = [
  "        - background_url: /#{opponent_id}/b1.png",
  "          chats:"
] + format_chat_lines(blocks, indent: "            ")

insert_at = conversations_abs + 1
yml_lines.insert(insert_at, *new_conversation_lines)

File.write(OPPONENTS_YML, yml_lines.join("\n") + "\n")

puts "Added #{blocks.length} chat blocks to #{opponent_id} cinematic level #{cinematic_level} in opponents.yml"
