# nanami -- Nano Markdown compiler
# Copyright (C) 2025 pokeghost
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# frozen_string_literal: true

require 'parslet'
require 'parslet/convenience'

module Nanami
  class Parser < Parslet::Parser
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:newline) { match('\n') }
    rule(:lbrace) { str('{') }
    rule(:rbrace) { str('}') }

    rule(:title) do
      str('title:') >> space? >> (newline.absent? >> any).repeat(1).as(:title) >> newline
    end

    rule(:text_block) do
      str('text') >> space? >> lbrace >> space? >>
        (str('}').absent? >> any).repeat(1).as(:text) >>
        space? >> rbrace
    end

    rule(:case_statement) do
      str('case(') >>
        (str(')').absent? >> any).repeat(1).as(:case_name) >>
        str(')') >> space? >> lbrace >> space? >>
        (text_block | case_statement).as(:case_body) >>
        space? >> rbrace
    end

    rule(:content) do
      str('content') >> space? >> lbrace >> space? >>
        case_statement.as(:content) >> space? >>
        rbrace
    end

    rule(:document) do
      space? >> title >>
        space? >> content.as(:content)
    end

    root(:document)
  end
end
