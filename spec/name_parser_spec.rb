require 'spec_helper'

class TestClass
  include NameParser
end

describe NameParser do
  let!(:name) { "Adams Jr., Mr. John Quincy" }
  let!(:test_class) { TestClass.new }

  describe '#name_parser' do
    it 'returns a new NameParser::Parser object' do
      test_class.name_parser(name).class.should == NameParser::Parser
    end

    it 'should run the parser' do
      parser = test_class.name_parser(name)
      parser.title.should == 'Mr.'
      parser.first.should == 'John'
      parser.middle.should == 'Quincy'
      parser.last.should == 'Adams'
      parser.suffix.should == 'Jr.'
    end
  end

  describe '.parse' do
    context "should parse punctuation-less name mixes" do
      it "should parse LAST FIRST M" do
        name = NameParser.parse("Collier Jonathan C")
        name.last.should eq "Collier"
        name.first.should eq 'Jonathan'
        name.middle.should eq 'C'
      end
      it "should parse LAST FIRST MIDDLE" do
        name = NameParser.parse("HALDEMAN BETTY ANN")
        name.last.should eq "Haldeman"
        name.first.should eq 'Betty'
        name.middle.should eq 'Ann'
      end
    end
    context "should fix capitalization" do
      it "should properly case a name" do
        name = NameParser.parse("HALDEMAN BETTY ANN")
        name.first.should eq 'Betty'
        name.middle.should eq 'Ann'
        name.last.should eq 'Haldeman'
      end

      it "should not explode when name parts are missing" do
        lambda {
          NameParser.parse("Phineas Gage")
        }.should_not raise_exception
      end
    end
  end
end

describe String do
  let!(:name) { "Adams Jr., Mr. John Quincy" }

  describe '#parse_name' do
    it 'returns a new NameParser::Parser object' do
      name.parse_name.class.should == NameParser::Parser
    end

    it 'should run the parser' do
      parser = name.parse_name
      parser.title.should == 'Mr.'
      parser.first.should == 'John'
      parser.middle.should == 'Quincy'
      parser.last.should == 'Adams'
      parser.suffix.should == 'Jr.'
    end
  end
end
