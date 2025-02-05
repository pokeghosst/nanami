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

require 'parslet/rig/rspec'
require 'parslet/convenience'

RSpec.describe Nanami do
  let(:nama_parser) { Nanami::NamaParser.new }
  let(:webography_parser) { Nanami::WebographyParser.new }
  let(:nama_transformer) { Nanami::NamaTransformer.new }

  it 'has a version number' do
    expect(Nanami::VERSION).not_to be nil
  end

  context 'parsers' do
    describe 'title' do
      subject { nama_parser.title }

      it 'can parse good titles' do
        inputs = [
          "title: test\n",
          "title:  test  \n",
          "title: test @#$%^&*(){\n"
        ]

        inputs.each do |input|
          expect(subject).to parse input
        end
      end

      it 'can\'t parse bad titles' do
        inputs = [
          "titleTitle\n",
          "title: \n",
          "title%:test\n",
          "title:\n",
          "title: test\nlorem\nipsum\n",
          'title: test'
        ]
        inputs.each do |input|
          expect(subject).not_to parse input
        end
      end
    end

    describe 'in-text elements' do
      subject { nama_parser.ref }

      describe 'ref' do
        it 'can parse refs' do
          input = '${smith2010}'
          expect(subject).to parse input
        end
      end

      describe 'links' do
        subject { nama_parser.link }

        it 'can parse good links' do
          input = [
            '{https://example.com}{click me}',
            '{https://example.com/path?q=123&x=y}{click}'
          ]

          expect(subject).to parse input
        end

        it 'can\'t parse bad links' do
          inputs = [
            '{https://example.com{click me}',
            '{https://example.com}click}',
            '{https://example.com}{anchor with {nested} braces}',
            '{}{Click here}',
            '{http://example.com}{}'
          ]

          inputs.each do |input|
            expect(subject).not_to parse input
          end
        end
      end
    end

    describe 'text_block' do
      subject { nama_parser.text_block }

      it 'can parse simple text' do
        expect(subject).to parse 'text { hello world }'
      end

      it 'can parse text with HTML tags' do
        expect(subject).to parse 'text { <p>hello</p> }'
      end

      it 'can parse text with refs' do
        expect(subject).to parse 'text { hello ${ref1} world }'
      end

      it 'can parse text with links' do
        expect(subject).to parse 'text { {https://example.com}{click} }'
      end

      it 'can parse text with images' do
        expect(subject).to parse 'text { {images/photo.jpg}{alt text} }'
      end

      it 'can parse text with self-closing tags' do
        expect(subject).to parse 'text { <br/> }'
      end

      it 'can parse mixed content' do
        expect(subject).to parse 'text { Hello <p>world</p> ${ref1} {https://example.com}{click here} and {image.jpg}{photo} <br/> more text }'
      end

      it 'can\'t parse bad content' do
        inputs = [
          'text hello hello',
          'text {',
          'text }'
        ]

        inputs.each do |input|
          expect(subject).not_to parse input
        end
      end
    end

    describe 'case_statement' do
      subject { nama_parser.case_statement }

      it 'can parse simple case' do
        expect(subject).to parse 'case(example) { text { hello } }'
      end

      it 'can parse case with link' do
        expect(subject).to parse 'case(hello)(https://example.com) { text { hello } }'
      end

      it 'can parse nested cases' do
        expect(subject).to parse 'case(outer) { case(inner) { text { hello } } }'
      end

      it 'can parse case with sources' do
        expect(subject).to parse 'case(example) { text { hello } sources { {footnotes} } }'
      end

      it 'can\'t parse bad cases' do
        inputs = [
          'case example { }',
          'case()',
          'case(example) text { hello }'
        ]

        inputs.each do |input|
          expect(subject).not_to parse input
        end
      end
    end

    describe 'sources' do
      subject { nama_parser.sources }

      it 'can parse empty sources' do
        expect(subject).to parse 'sources { }'
      end

      it 'can parse non-empty sources' do
        expect(subject).to parse 'sources { {footnotes} }'
      end

      it 'can\'t parse bad sources' do
        inputs = [
          'sources',
          'sources {',
          'sources }',
          'sources { footnotes }',
          'sources { {footnotes} other }'
        ]

        inputs.each do |input|
          expect(subject).not_to parse input
        end
      end
    end

    describe 'content' do
      subject { nama_parser.content }

      it 'can parse empty content' do
        expect(subject).to parse 'content { }'
      end

      it 'can parse simple content' do
        expect(subject).to parse 'content { case(example) { text { hello } } }'
      end

      it 'can parse multiple cases' do
        expect(subject).to parse 'content {
        case(first) { text { hello } }
        case(second) { text { world } }
      }'
      end

      it 'can\'t parse bad content' do
        inputs = [
          'content',
          'content {',
          'content } }'
        ]

        inputs.each do |input|
          expect(subject).not_to parse input
        end
      end
    end

    describe 'document' do
      subject { nama_parser }

      it 'can parse minimal document' do
        expect(subject).to parse "title: hello\ncontent { }"
      end

      it 'can parse document with nlp flag' do
        expect(subject).to parse "title: hello\n!nlp\ncontent { }"
      end

      it 'can parse benchmark document' do
        input = "title: first test
                 !nlp
                 content {
                     case(hello)(https://example.com) {
                         text {
                             <b>I exist!</b>${smthiread}${anthrthngiread}
                             <br/>
                             I use {https://example.com}{example} as an example a lot.
                             {img/someimg.ff}{A random image in the farbfeld format}
                         }
                         sources {
                             {footnotes}
                         }
                     }
                 }"
        expect(subject).to parse input
      end

      it 'can\'t parse bad document' do
        inputs = [
          'content { }',
          'title: hello',
          "!nlp\ncontent { }"
        ]

        inputs.each do |input|
          expect(subject).not_to parse input
        end
      end
    end

    describe 'webography' do
      subject { webography_parser }

      it 'can parse title' do
        expect(subject.title).to parse 'T: lorem ipsum'
      end

      it 'can parse link' do
        expect(subject.link).to parse 'L: https://example.com'
      end

      it 'can parse name' do
        expect(subject.name).to parse 'N: Something I Read'
      end

      it 'can parse date' do
        expect(subject.date).to parse 'D: 2019'
      end

      it 'can parse a single source' do
        expect(subject.source).to parse 'T: smthiread
               L: https://example.com/whatever.xhtml
	             N: Something I Read
	             D: 2019'
      end

      it 'can\'t parse source with missing fields' do
        expect(subject).not_to parse 'T: smthiread
	             N: Something I Read
	             D: 2019'
      end

      it 'can\'t parse source with mixed field order' do
        expect(subject).not_to parse 'T: smthiread
               N: Something I Read
               L: https://example.com/whatever.xhtml
	             D: 2019'
      end

      it 'can\'t parse source with extra fields' do
        expect(subject).not_to parse 'T: smthiread
               L: https://example.com/whatever.xhtml
	             N: Something I Read
	             D: 2019
               E: who are you'
      end

      it 'can parse full webography' do
        expect(subject).to parse 'T: smthiread
               L: https://example.com/whatever.xhtml
               N: Something I Read
               D: 2019

               T: anthrthngiread
               L: https://example.com/sowhat.xhtml
               N: Another Thing I Read
               D: 2020'
      end
    end
  end
end

