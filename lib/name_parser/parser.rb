module NameParser
  class Parser
    include Patterns

    attr_reader :first, :middle, :last, :title, :suffixes

    def initialize(name)
      @name = name.dup
      @suffixes = []
      run
    end

    def suffix
      @suffixes.first
    end

    protected

      def run
        remove_non_name_characters
        remove_extra_spaces
        clean_trailing_suffixes
        reverse_last_and_first_names
        remove_commas
        parse_title
        parse_suffixes
        parse_name
        fix_cases
      end

      def remove_non_name_characters
        @name.gsub!(/[^A-Za-z0-9\-\'\.&\/ \,]/, '')
      end

      def remove_extra_spaces
        @name.gsub!(/\s+/, ' ')
        @name.strip!
      end

      def clean_trailing_suffixes
        while(!@name.gsub!(Regexp.new("(.+), (%s)" % SUFFIX_PATTERN, true), "\\1 \\2").nil?) do
        end
      end

      def reverse_last_and_first_names
        # If the second name is in the nicknames list, then the format is probably LAST FIRST MIDDLE without commas
        #debugger if @name == 'Collier Jonathan C'
        #debugger
        if NickNames[@name.split(' ')[1]].length > NickNames[@name.split(' ')[0]].length
          @name.gsub!(/(#{@name.split(' ')[0]}) /, "\\1,")
        end

        @name.gsub!(/;/, '')
        @name.gsub!(/(.+),(.+)/, "\\2 ;\\1")
        @name.strip!
      end

      def remove_commas
        @name.gsub!(/,/, '')
      end

      def parse_title
        if match = @name.match(Regexp.new("^(%s) (.+)" % TITLE_PATTERN, true))
          @name = match[-1]
          @title = match[1].strip
        end
      end

      def parse_suffixes
        # p @name
        while(match = @name.match(Regexp.new("(.+) (%s)$" % SUFFIX_PATTERN, true))) do
          @name = match[1].strip
          # puts "parsing suffix: #{@name}"
          @suffixes << match[2]
        end
      end

      def parse_name
        case
          when match = @name.match(Regexp.new('^%s%s$' % [ NAME_PATTERN, LAST_NAME_PATTERN ], true))
            @first, @last = match.captures
          when match = @name.match(Regexp.new('^%s%s%s%s$' % [ NAME_PATTERN, NAME_PATTERN, NAME_PATTERN, LAST_NAME_PATTERN ], true))
            @first, *middles, @last = match.captures[0..3]
            @middle = middles.join(' ')
          when match = @name.match(Regexp.new('^%s%s%s$' % [ NAME_PATTERN, NAME_PATTERN, LAST_NAME_PATTERN ], true))
            @first, @middle, @last = match.captures
        end
      end

      def fix_cases
        [:first, :middle, :last].each do |part|
          self.instance_variable_get("@#{part}").capitalize! if self.instance_variable_get("@#{part}").respond_to?(:capitalize)
        end
      end
  end
end