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
  class Parser < Parslet::Parser
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:newline) { match('\n') }
    rule(:lbrace) { str('{') }
    rule(:rbrace) { str('}') }

    rule(:title) do
      str('title:') >> space? >> (newline.absent? >> any).repeat(1).as(:title) >> newline
    end

    # ${ref}
    rule(:ref) do
      str('$') >> lbrace >>
        match['a-zA-Z0-9_'].repeat(1).as(:ref) >>
        rbrace
    end

    rule(:html_attribute_value) { str('"') >> (str('"').absent? >> any).repeat >> str('"') }

    rule(:html_attribute) { match['a-zA-Z'].repeat(1) >> (str('=') >> html_attribute_value).maybe }

    rule(:html_tag) do
      str('<') >>
        str('/').maybe >>
        match['a-zA-Z'].repeat(1).as(:tag_name) >>
        (space >> html_attribute).repeat.as(:attributes) >>
        space? >>
        str('>')
    end

    rule(:self_closing_tag) do
      str('<') >>
        match['a-zA-Z'].repeat(1).as(:tag_name) >>
        (space >> html_attribute).repeat.as(:attributes) >>
        space? >>
        str('/>')
    end

    rule(:url_char) do
      match['a-zA-Z0-9\-._~:/?#\[\]@!$&\'*+,;=']
    end

    rule(:path_char) do
      match['a-zA-Z0-9\-._/']
    end

    # {url}{text}
    rule(:link) do
      lbrace >>
        url_char.repeat(1).as(:url) >>
        rbrace >> lbrace >>
        (lbrace.absent? >> rbrace.absent? >> any).repeat(1).as(:link_text) >>
        rbrace
    end

    # {path.ff}{description}
    rule(:image) do
      lbrace >>
        path_char.repeat(1).as(:img_path) >>
        rbrace >> lbrace >>
        (lbrace.absent? >> rbrace.absent? >> any).repeat(1).as(:img_desc) >>
        rbrace
    end

    rule(:text_content) do
      (
        ref.as(:ref) |
          image.as(:img) |
          link.as(:link) |
          self_closing_tag.as(:self_closing) |
          html_tag.as(:html) |
          (ref.absent? >> image.absent? >> link.absent? >>
            html_tag.absent? >> self_closing_tag.absent? >> str('}').absent? >> any).repeat(1).as(:plain)
      ).repeat(1)
    end

    rule(:text_block) do
      str('text') >> space? >> lbrace >> space? >>
        text_content.as(:text) >>
        space? >> rbrace
    end

    rule(:sources) do
      str('sources') >> space? >> lbrace >> space? >>
        (str('{footnotes}').as(:footnotes) >> space?).maybe >>
        rbrace
    end

    rule(:case_content) do
      (text_block | case_statement)
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
        space? >> lbrace >> space? >>
        case_content.repeat(0).as(:case_body) >>
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
