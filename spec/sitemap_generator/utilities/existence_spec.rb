require 'spec_helper'

class EmptyTrue
  def empty?() true; end
end

class EmptyFalse
  def empty?() false; end
end

BLANK = [ EmptyTrue.new, nil, false, '', '   ', "  \n\t  \r ", [], {} ]
NOT   = [ EmptyFalse.new, Object.new, true, 0, 1, 'a', [nil], { nil => 0 } ]

describe Object do
  let(:utils) { SitemapGenerator::Utilities }

  it "should define blankness" do
    BLANK.each { |v| expect(utils.blank?(v)).to be_true }
    NOT.each   { |v| expect(utils.blank?(v)).to be_false }
  end

  it "should define presence" do
    BLANK.each { |v| expect(utils.present?(v)).to be_false }
    NOT.each   { |v| expect(utils.present?(v)).to be_true }
  end
end
