class ScriptToConversationService
  def call(text)
    sentences = split_into_sentences(text)
    blocks = []

    sentences.each do |sentence|
      parse_segments(sentence).each do |seg|
        if seg[:type] == :dialogue
          blocks << { "role" => "hero", "content" => seg[:content] }
        else
          blocks << { "role" => "other", "content" => "(#{seg[:content]})" }
        end
      end
    end

    blocks
  end

  private

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

        if !in_quotes
          # After closing quote: consume optional trailing punct, then split.
          if i < text.length && %w[. ! ?].include?(text[i]) && text[i, 3] != "..."
            current << text[i]
            i += 1
          end
          sentences << current.strip unless current.strip.empty?
          current = +""
        end
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
      elsif ch == "." || ch == "!" || ch == "?"
        current << ch
        sentences << current.strip unless current.strip.empty?
        # If we split mid-quote, reopen the quote on the next sentence so
        # parse_segments still recognises the continuation as dialogue.
        current = in_quotes ? +"\"" : +""
        i += 1
      else
        current << ch
        i += 1
      end
    end

    sentences << current.strip unless current.strip.empty?
    sentences
  end

  def parse_segments(sentence)
    segments = []
    rest = sentence.dup

    while rest.length > 0
      open_idx = rest.index('"')

      if open_idx.nil?
        segments << { type: :narrative, content: rest.strip } unless rest.strip.gsub(/[[:punct:]]/, "").empty?
        break
      end

      before = rest[0, open_idx].strip
      segments << { type: :narrative, content: before } unless before.gsub(/[[:punct:]]/, "").empty?

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
end
