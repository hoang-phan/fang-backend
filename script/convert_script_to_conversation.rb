#!/usr/bin/env ruby
# Usage: ruby script/convert_script_to_conversation.rb <story_file.txt> [OPTIONS]
#
# Without targeting options: prints the chat blocks to stdout.
#
# Cinematic:  --id <opponent_id> --level <n>
# Gift:       --id <opponent_id> --gift <gift-name-slug>
# Chat:       --id <opponent_id> --chat
#
# In all three cases, the conversation is appended to the matching
# db/seeds/conversations/<file>.yml (creating it if it doesn't exist yet).

require "optparse"
require "yaml"

SEEDS_DIR    = File.expand_path("../db/seeds", __dir__)
CONV_DIR     = File.join(SEEDS_DIR, "conversations")
OPPONENTS_YML = File.join(SEEDS_DIR, "opponents.yml")

options = {}
parser = OptionParser.new do |opts|
  opts.on("--id ID",      "Opponent id (e.g. illyasviel)")
  opts.on("--level N",    Integer, "Cinematic level number")
  opts.on("--gift SLUG",  "Gift name slug (e.g. tulip-bouquet)")
  opts.on("--chat",       "Append to opponent-level random conversations")
end
parser.parse!(into: options)

story_file = ARGV[0]
abort "Usage: #{$0} <story_file.txt> [--id <id> --level <n> | --gift <slug> | --chat]" unless story_file
abort "File not found: #{story_file}" unless File.exist?(story_file)

targeting = [options[:level], options[:gift], options[:chat]].compact
if options[:id] && targeting.size > 1
  abort "Only one of --level, --gift, or --chat may be specified at a time."
end
if options[:id] && targeting.empty?
  abort "With --id, also provide --level <n>, --gift <slug>, or --chat."
end
if targeting.any? && options[:id].nil?
  abort "--id is required when using --level, --gift, or --chat."
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

# Legacy quote-based parser. Prefer ConversationEditor::ScriptToConversationService
# (named-speaker scripts). Mapping: dialogue → "Mitsu", narrative → blank speaker.
blocks = []
sentences.each do |sentence|
  parse_segments(sentence).each do |seg|
    if seg[:type] == :dialogue
      blocks << { speaker: "Mitsu", content: seg[:content] }
    else
      blocks << { speaker: "", content: "(#{seg[:content]})" }
    end
  end
end

# Build indented chat lines (12-space indent to match opponents.yml)
def format_chat_lines(blocks, indent: "            ")
  lines = []
  blocks.each do |block|
    speaker = block[:speaker].to_s
    lines << (speaker.empty? ? "#{indent}- speaker: \"\"" : "#{indent}- speaker: #{speaker}")
    lines << "#{indent}  content: #{block[:content]}"
  end
  lines
end

unless options[:id]
  puts format_chat_lines(blocks)
  exit
end

# --- Write mode: append conversation to the matching conversations file ---

require "fileutils"
FileUtils.mkdir_p(CONV_DIR)

opponent_id = options[:id]

conv_filename =
  if options[:level]
    "#{opponent_id}-cinematic-#{options[:level]}.yml"
  elsif options[:gift]
    "#{opponent_id}-gift-#{options[:gift]}.yml"
  else
    "#{opponent_id}-conversations.yml"
  end

conv_path = File.join(CONV_DIR, conv_filename)
is_new_file = !File.exist?(conv_path)

# Load existing conversations or start fresh
existing = is_new_file ? [] : (YAML.load_file(conv_path) || [])

new_conversation = { "chats" => blocks.map { |b| { "speaker" => b[:speaker], "content" => b[:content] } } }
# Cinematics get a background_url placeholder if file is brand new
if options[:level] && is_new_file
  new_conversation = { "background_url" => "/#{opponent_id}/cinematic#{options[:level]}.webp" }.merge(new_conversation)
end

existing << new_conversation
File.write(conv_path, existing.to_yaml)

if is_new_file
  puts "Note: wire up #{conv_filename} in opponents.yml under the matching conversations: key."
end

label =
  if options[:level]    then "#{opponent_id} cinematic level #{options[:level]}"
  elsif options[:gift]  then "#{opponent_id} gift #{options[:gift]}"
  else                       "#{opponent_id} random conversations"
  end

puts "Appended #{blocks.length} chat blocks to #{label} in #{conv_filename}"
