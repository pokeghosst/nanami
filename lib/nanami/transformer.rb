# frozen_string_literal: true

require 'parslet'
module Nanami
  class Transformer < Parslet::Transform
    rule(title: simple(:title)) { title.to_s.strip }
  end
end
