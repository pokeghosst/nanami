# frozen_string_literal: true

require 'parslet/rig/rspec'

RSpec.describe Nanami do
  let(:parser) { Nanami::Parser.new }
  let(:transformer) { Nanami::Transformer.new }

  it 'has a version number' do
    expect(Nanami::VERSION).not_to be nil
  end

  describe 'title' do
    it 'can parse well-formed title' do
      input = "title: test\n"
      expect(parser.title).to parse(input)
      result = parser.title.parse(input)
      expect(result[:title].to_s.strip).to eq('test')
    end

    it 'can parse title with multiple spaces' do
      input = "title:  test  \n"
      expect(parser.title).to parse(input)
      result = parser.title.parse(input)
      expect(result[:title].to_s.strip).to eq('test')
    end

    it 'fails on malformed title' do
      expect(parser.title).not_to parse("titleTitle\n")
      expect(parser.title).not_to parse("title: \n")
      expect(parser.title).not_to parse('title: test')
    end
  end

  describe 'text' do
    it 'can parse well-formed text block' do
      input = "text {
				I exist!
			}"
      expect(parser.text_block).to parse(input)
      result = parser.text_block.parse(input)
      expect(result[:text].to_s.strip).to eq('I exist!')
    end
  end

  describe 'case' do
    it 'can parse well-formed case block' do
      input = "case(hello) {
			text {
				I exist!
			}
		  }"
      # expect(parser.case_statement).to parse(input)
      parser.case_statement.parse_with_debug(input)
    end
  end
end
