require 'spec_helper'

class TestClass
  include NameParser
end

describe NameParser do
  let!(:name) { 'Adams Jr., Mr. John Quincy' }
  let!(:test_class) { TestClass.new }

  describe '#name_parser' do
    it 'returns a new NameParser::Parser object' do
      test_class.name_parser(name).class.should == NameParser::Parser
    end

    it 'should run the parser' do
      parser = test_class.name_parser(name, messy_data: true)
      parser.title.should eq 'Mr.'
      parser.first.should eq 'John'
      parser.middle.should eq 'Quincy'
      parser.last.should eq 'Adams'
      parser.suffix.should eq 'Jr.'
    end
  end

  describe 'parsing multiple suffixes' do
    it 'should parse correctly' do
      name = NameParser.parse('David L. Bradfute, Ph.D., J.D.')
      name.last.should eq 'Bradfute'
      name.first.should eq 'David'
      name.middle.should eq 'L'
      name.suffixes.should eq ['J.D.', 'Ph.D.']
      name.first_initial.should eq 'D'
      name.middle_initial.should eq 'L'
      name.last_initial.should eq 'B'
    end
  end

  describe '.parse' do

    it 'should handle first names only' do
      NameParser.parse('Jon').first.should eq 'Jon'
      NameParser.parse('Jon J.D.').first.should eq 'Jon'
      NameParser.parse('Jon J.D.').suffixes.should eq ['J.D.']
    end

    context 'with messy data' do
      context 'should parse punctuation-less name mixes if the data is messy' do
        it 'checks for reversed names' do
          NameParser.parse('Jon Collier').first.should eq 'Jon'
        end

        it 'parses LAST FIRST M' do
          name = NameParser.parse('Collier Jonathan C', messy_data: true)
          name.last.should eq 'Collier'
          name.first.should eq 'Jonathan'
          name.middle.should eq 'C'
        end
        it 'parses LAST FIRST MIDDLE' do
          name = NameParser.parse('HALDEMAN BETTY ANN', messy_data: true)
          name.last.should eq 'Haldeman'
          name.first.should eq 'Betty'
          name.middle.should eq 'Ann'
        end
      end
    end

    context 'with non-messy data' do
      it 'does not check for reversed names' do
        NameParser.parse('Collier Jon', messy_data: true).first.should eq 'Jon'
      end
    end

    context 'should fix capitalization' do
      it 'should properly case a name' do
        name = NameParser.parse('BETTY ANN HALDEMAN')
        name.first.should eq 'Betty'
        name.middle.should eq 'Ann'
        name.last.should eq 'Haldeman'
      end

      it 'should not explode when name parts are missing' do
        lambda do
          NameParser.parse('Phineas Gage')
        end.should_not raise_exception
      end
    end
  end
end

describe String do
  let!(:name) { 'Adams Jr., Mr. John Quincy' }

  describe '#parse_name' do
    it 'returns a new NameParser::Parser object' do
      name.parse_name.class.should == NameParser::Parser
    end

    it 'correctly parses Adams Jr., Mr. John Quincy' do
      parser = name.parse_name(messy_data: true)
      parser.title.should eq 'Mr.'
      parser.first.should eq 'John'
      parser.middle.should eq 'Quincy'
      parser.last.should eq 'Adams'
      parser.suffix.should eq 'Jr.'
    end
  end
end
