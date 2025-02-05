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
  # Transforms atoms, making them ready for render
  class NamaTransformer < Parslet::Transform
    HTML5_TEMPLATE = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
      <title>%<title>s</title>
      </head>
      <body>
      <h1>%<title>s</h1>
      %<content>s
      </body>
      </html>
    HTML

    # TODO: Brain not working now, handle refs properly later
    rule(ref: simple(:ref)) { ref.to_s }
    rule(raw: simple(:text)) { text.to_s }
    rule(title: simple(:title)) { title.to_s }
    rule(case_name: simple(:case_name)) { 'not case name' }

    rule(
      link: {
        url: simple(:url),
        link_text: simple(:text)
      }
    ) do
      "<a href=\"#{url}\">#{text}</a>"
    end

    rule(
      img: {
        img_path: simple(:path),
        img_desc: simple(:desc)
      }
    ) do
      "<img src=\"#{path}\" alt=\"#{desc}\">"
    end

    # TODO: Handle sources and footnotes properly according to NAMAC
    rule(sources: sequence(:_)) { '<div class="sources"></div>' }
    rule(footnotes: simple(:_)) { '<div class="footnotes"></div>' }

    rule(content: sequence(:cases)) do
      print("\n\nprocessing case NOW\n\n")
      processed_cases = cases.map do |case_data|
        "<div class=\"case\" data-name=\"#{case_data[:case_name]}\"#{
          case_data[:case_url] ? " data-url=\"#{case_data[:case_url]}\"" : ''
        }>"
      end

      "<div class=\"content\">#{processed_cases.join}</div>"
    end

    # TODO: Don't forget to handle nlp
    rule(
      title: simple(:title),
      content: sequence(:content)
    ) do
      print("\n\nprocessing DOCUMENT\n\n")
      # format(HTML5_TEMPLATE,
      #        title: title,
      #        content: content)
    end
  end
end
