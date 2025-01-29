# frozen_string_literal: true

require 'parslet/rig/rspec'

RSpec.describe Nanami do
  let(:parser) { Nanami::Parser.new }
  let(:transformer) { Nanami::Transformer.new }

  it 'has a version number' do
    expect(Nanami::VERSION).not_to be nil
  end

  describe 'title' do
    it 'parses regular title' do
      input = "title: test\n"
      expect(parser.title).to parse(input)
      result = parser.title.parse(input)
      expect(result[:title].to_s.strip).to eq('test')
    end

    it 'parses title with multiple spaces' do
      input = "title:  test  \n"
      expect(parser.title).to parse(input)
      result = parser.title.parse(input)
      expect(result[:title].to_s.strip).to eq('test')
    end

    it 'fails on invalid title format' do
      expect(parser.title).not_to parse("titleTitle\n")
      expect(parser.title).not_to parse("title: \n")
      expect(parser.title).not_to parse('title: test')
    end
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
