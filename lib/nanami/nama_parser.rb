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

module Nanami
  # Parses .nama files
  class NamaParser < Parslet::Parser
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:newline) { match('\n') }

    rule(:title) do
      str('title:') >> space? >> (newline.absent? >> any).repeat(1).as(:title) >> newline
    end

    rule(:ref) do
      str('${') >>
        match['a-zA-Z0-9_'].repeat(1).as(:ref) >>
        str('}')
    end

    rule(:url_char) do
      match['a-zA-Z0-9\-._~:/?#\[\]@!$&\'*+,;=']
    end

    rule(:path_char) do
      match['a-zA-Z0-9\-._/']
    end

    rule(:link) do
      str('{') >>
        url_char.repeat(1).as(:url) >>
        str('}') >> str('{') >>
        (str('{').absent? >> str('}').absent? >> any).repeat(1).as(:link_text) >>
        str('}')
    end

    rule(:image) do
      str('{') >>
        path_char.repeat(1).as(:img_path) >>
        str('}') >> str('{') >>
        (str('{').absent? >> str('}').absent? >> any).repeat(1).as(:img_desc) >>
        str('}')
    end

    rule(:text_content) do
      (
        ref.as(:ref) |
          image.as(:img) |
          link.as(:link) |
          ((ref | image | link | str('}')).absent? >> any).repeat(1).as(:raw)
      ).repeat(1)
    end

    rule(:text_block) do
      str('text') >> space? >> str('{') >> space? >>
        text_content.as(:text) >>
        space? >> str('}')
    end

    rule(:sources) do
      str('sources') >> space? >> str('{') >> space? >>
        (str('{footnotes}').as(:footnotes) >> space?).maybe >>
        str('}')
    end

    rule(:case_content) do
      space? >> (text_block | case_statement | sources)
    end

    rule(:case_statement) do
      str('case(') >>
        (str(')').absent? >> any).repeat(1).as(:case_name) >>
        str(')') >>
        (
          str('(') >>
            url_char.repeat(1).as(:case_url) >>
            str(')')
        ).maybe >>
        space? >> str('{') >> space? >>
        case_content.repeat(1).as(:case_body) >>
        space? >> str('}')
    end

    rule(:nlp) { str('!nlp') }

    rule(:content) do
      space? >> str('content') >> space? >> str('{') >> space? >>
        (case_statement >> space?).repeat(0).as(:content) >> space? >>
        str('}')
    end

    rule(:document) do
      space? >> title >>
        space? >> nlp.maybe >>
        space? >> content
    end

    root(:document)
  end

  # Parses webography file
  class WebographyParser < Parslet::Parser
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:newline) { match('\n') }
    rule(:blank_line) { newline >> newline }

    rule(:field_value) { (newline.absent? >> any).repeat(1) }

    rule(:title) { str('T: ') >> field_value.as(:title) }
    rule(:link) { str('L: ') >> field_value.as(:link) }
    rule(:name) { str('N: ') >> field_value.as(:name) }
    rule(:date) { str('D: ') >> field_value.as(:date) }

    rule(:source) do
      (space? >> title >> newline >>
        space? >> link >> newline >>
        space? >> name >> newline >>
        space? >> date >> space?)
    end

    rule(:webography) do
      (source >> blank_line.maybe).repeat.as(:sources)
    end

    root(:webography)

  end
end
