# frozen_string_literal: true

require 'parslet'

module Nanami
  class Parser < Parslet::Parser
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:newline) { match('\n') }

    rule(:title) { str('title:') >> space? >> match('[^\n]').repeat(1).as(:title) >> newline }

    # rule(:content) { str('content') >> space? >> str('{') >> newline | space? >>  case_block.as(:content) >> newline | space? >> str('}') }

    rule(:document) { space? >> title }

    root(:document)
  end
end
