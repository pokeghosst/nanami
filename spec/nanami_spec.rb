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
  let(:nama_transformer) { Nanami::Transformer.new }
  let(:webography_parser) { Nanami::WebographyParser.new }

  it 'has a version number' do
    expect(Nanami::VERSION).not_to be nil
  end

  describe 'title' do
    it 'can parse well-formed title' do
      input = "title: test\n"
      expect(nama_parser.title).to parse(input)
      result = nama_parser.title.parse(input)
      expect(result[:title].to_s.strip).to eq('test')
    end

    it 'can parse title with multiple spaces' do
      input = "title:  test  \n"
      expect(nama_parser.title).to parse(input)
      result = nama_parser.title.parse(input)
      expect(result[:title].to_s.strip).to eq('test')
    end

    it 'fails on malformed title' do
      expect(nama_parser.title).not_to parse("titleTitle\n")
      expect(nama_parser.title).not_to parse("title: \n")
      expect(nama_parser.title).not_to parse('title: test')
    end
  end

  describe 'in-text elements' do
    it 'can parse references' do
      input = '${smith2010}'
      expect(nama_parser.ref).to parse(input)
      result = nama_parser.ref.parse(input)
      expect(result[:ref].to_s.strip).to eq('smith2010')
    end
  end

  describe 'text' do
    it 'can parse well-formed text block' do
      input = "text {
				I exist!
			}"
      expect(nama_parser.text_block).to parse(input)
      result = nama_parser.text_block.parse(input)
      expect(result[:text].first[:plain].to_s.strip).to eq('I exist!')
    end

    it 'can parse complicated texts' do
      input = %(text {
                        <div class="container">
                          As per ${Jones2012}...
                          <custom-element data-test="value">
                            Check out {https://example.com/path?q=1}{our website}
                            <br/>
                            <img-v2 src="test.jpg"/>
                          </custom-element>
                          Here's an image: {assets/images/test.ff}{A test image}
                        </div>
                      })
      result = nama_parser.text_block.parse(input)
      print result
    end
  end

  describe 'sources' do
    it 'can parse well-formed sources' do
      input = "sources {
							    {footnotes}
					      }"
      expect(nama_parser.sources).to parse(input)
    end
  end

  describe 'case' do
    it 'can parse well-formed case block' do
      input = "case(hello) {
			  text {
				  I exist!
			  }
		  }"
      expect(nama_parser.case_statement).to parse(input)
      result = nama_parser.case_statement.parse(input)
      expect(result[:case_name].to_s.strip).to eq('hello')
      expect(result[:case_body].first[:text].first[:plain].to_s.strip).to eq('I exist!')
    end

    it 'can parse minified case block' do
      input = 'case(hello){text{I exist!}}'
      expect(nama_parser.case_statement).to parse(input)
      result = nama_parser.case_statement.parse(input)
      expect(result[:case_name].to_s.strip).to eq('hello')
      expect(result[:case_body].first[:text].first[:plain].to_s.strip).to eq('I exist!')
    end

    it 'can parse recursive case blocks' do
      input = "case(hello) {
        case(world) {
          text {
            I exist!
          }
        }
      }"
      expect(nama_parser.case_statement).to parse(input)
      result = nama_parser.case_statement.parse(input)
      expect(result[:case_name].to_s.strip).to eq('hello')
      expect(result[:case_body].first[:case_name].to_s.strip).to eq('world')
      expect(result[:case_body].first[:case_body].first[:text].first[:plain].to_s.strip).to eq('I exist!')
    end

    it 'can parse case with link' do
      input = 'case(hello)(https://example.com){text{I exist!}}'
      expect(nama_parser.case_statement).to parse(input)
      result = nama_parser.case_statement.parse(input)
      expect(result[:case_url].to_s.strip).to eq('https://example.com')
    end

    it 'can parse case with sources' do
      input = 'case(hello) {
                  sources {
                    {footnotes}
                  }
               }'
      result = nama_parser.case_statement.parse_with_debug(input)
      # This will be transformed to boolean flag, for test it's fine to check existence
      expect(result[:case_body].first[:footnotes].to_s.strip).to eq('{footnotes}')
    end
  end

  describe 'content' do
    it 'can parse well-formed content block' do
      input = "content {
		    case(hello) {
			    text {
				    I exist!
			    }
		    }
	    }"
      expect(nama_parser.content).to parse(input)
      result = nama_parser.content.parse(input)
      expect(result[:content].first[:case_name].to_s.strip).to eq('hello')
      expect(result[:content].first[:case_body].first[:text].first[:plain].to_s.strip).to eq('I exist!')
    end

    describe 'parser' do
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
        nama_parser.parse_with_debug input
        expect(nama_parser).to parse input
        result = nama_parser.parse input
        print result
        expect(result[:title].to_s.strip).to eq('first test')
        expect(result[:content][:content].first[:case_name].to_s.strip).to eq('hello')
        expect(result[:content][:content].first[:case_body].first[:text][1][:plain].to_s.strip).to eq('I exist!')
      end
    end
  end

  describe 'webography' do
    it 'can parse a single source' do
      input = '	  T: smthiread
                  L: https://example.com/whatever.xhtml
	                N: Something I Read
	                D: 2019
               '

      expect(webography_parser.source).to parse input
      result = webography_parser.source.parse input

      expect(result[:title].to_s.strip).to eq('smthiread')
      expect(result[:link].to_s.strip).to eq('https://example.com/whatever.xhtml')
      expect(result[:name].to_s.strip).to eq('Something I Read')
      expect(result[:date].to_s.strip).to eq('2019')
    end

    it 'can parse full webography' do
      input = '	T: smthiread
                L: https://example.com/whatever.xhtml
                N: Something I Read
                D: 2019

                T: anthrthngiread
                L: https://example.com/sowhat.xhtml
                N: Another Thing I Read
                D: 2020'
      expect(webography_parser).to parse input
      result = webography_parser.parse input
      expect(result[:sources].first[:title].to_s.strip).to eq('smthiread')
      expect(result[:sources].first[:link].to_s.strip).to eq('https://example.com/whatever.xhtml')
      expect(result[:sources].first[:name].to_s.strip).to eq('Something I Read')
      expect(result[:sources].first[:date].to_s.strip).to eq('2019')
    end
  end
end
