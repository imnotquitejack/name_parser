module Parsely
  module Person
    class Name
      include NameConstants
    
      attr_reader :original
      attr_reader :couple
      attr_reader :proper
      
      attr_reader :sanitized
      attr_reader :parse_name
      
      alias :couple? :couple
      alias :proper? :proper
      
      def initialize(name, opts={})
        @original  = name
        @sanitized = name.dup
        
        @couple    = opts[:couple].nil? ? false : opts[:couple]
        @proper    = opts[:proper].nil? ? true  : opts[:proper]
        
        sanitize
      end
      
      def name
        return @name if defined?(@name)
        @name = build_name
      end
      alias :to_s :name
      
      def to_hash
        return @hash if defined?(@hash)
        @hash = {:title => title, :first => first, :middle => middle, :last => last, :suffix => suffix}
      end
      
      def first
        return @first if defined?(@first)
        @first = parse_first
      end
      
      def middle
        return @middle if defined?(@middle)
        @middle = parse_middle
      end
      
      def last
        return @last if defined?(@last)
        @last = parse_last
      end
      
      def title
        return @title if defined?(@title)
        @title = parse_title
      end
      
      def suffix
        return @suffix if defined?(@suffix)
        @suffix = parse_suffix
      end
      
      def parse_name
        return @parse_name if defined?(@parse_name)
        @parse_name = sanitized.gsub(title, '').gsub(suffix, '').strip
      end
      
      def [](attr)
        self.send attr.to_sym
      end
      
      private
      
        def sanitize
          remove_repeating_spaces
          remove_illegal_characters
          format_for_multiple_names if couple?
          clean_marriage_titles
          format_first_last_name
          remove_commas
          strip_spaces
        end
        
        def remove_illegal_characters
          sanitized.gsub!(ILLEGAL_CHARACTERS, '')
        end
   
        def remove_repeating_spaces
          sanitized.gsub!(/  +/, ' ')
          sanitized.gsub!(REPEATING_SPACES, ' ')
        end
        
        def strip_spaces
          sanitized.strip!
        end
        
        def clean_marriage_titles
          sanitized.gsub!(/Mr\.? \& Mrs\.?/i, 'Mr. and Mrs.')
        end
        
        def format_first_last_name
          sanitized.gsub!(/(.+),(.+)/, "\\2 \\1")
        end
        
        def remove_commas
          sanitized.gsub!(/,/, '')
        end
        
        def format_for_multiple_names
          sanitized.gsub!(/ +and +/i, " \& ")
        end
        
        def parse_first
          first_name = ''
          first_name_pattern = Regexp.new("^([#{NAME_PATTERN}]+)", true)
          if match = parse_name.match(first_name_pattern)
            first_name = match[1].strip
            first_name = first_name.titleize if proper?
          end
          first_name
        end
        
        def parse_middle
          middle_name = ''
          middle_name_pattern = Regexp.new("#{first}(.*?)#{last}")
          if match = parse_name.match(middle_name_pattern)
            middle_name = match[1].strip
            middle_name = middle_name.titleize if proper?
          end
          middle_name
        end
        
        def parse_last
          last_name = ''
          last_name_pattern = Regexp.new("#{LAST_NAME_PATTERN}", true)
          if match = parse_name.match(last_name_pattern)
            last_name = match[1].strip
            last_name = last_name.titleize if proper?
          end
          last_name
        end
    
        def parse_title
          title = ''
          if title_match = sanitized.match(Regexp.new(TITLES_PATTERN, true))
            title = title_match[1].strip
          end      
          title
        end
        
        def parse_suffix
          suffix = ''
          if suffix_match = sanitized.match(Regexp.new(SUFFIXES_PATTERN, true))
            suffix = suffix_match[2].strip
          end       
          suffix
        end
        
        def build_name
          name_parts = []
          name_parts << title unless title.nil? || title == ''
          name_parts << first unless first.nil? || first == ''
          name_parts << middle unless middle.nil? || middle == ''
          name_parts << last unless last.nil? || last == ''
          name_parts << suffix unless suffix.nil? || suffix == ''
          name_parts.join(' ')
        end
    end
  end
end