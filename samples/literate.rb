require 'cooloptions'

options = CoolOptions.parse!('[options] NAME') do |cooloptions|
  cooloptions.desc 'This is a literate sample of what CoolOptions can do.'  # Adds some extra descriptive text.
  cooloptions.on 'option STRING',  'Description', 'default' # Matches '-o string' or '--option string' or uses the 'default'.

  cooloptions.on 'required VALUE', 'Required'               # Because there's no default, the option is required.

  cooloptions.on 'boolean',        'Boolean',      false    # Matches '-b' or '--boolean' or '--no-boolean'.
                                                            # Note the lack of a placeholder for the value.

  cooloptions.on 'shor(t) VALUE',  'Short'                  # Use parens to delineate a short form other than the first char.
                                                            # Matches '-o value' or '--short value'

  cooloptions.on 'k)first VALUE',  'First'                  # No leading paren for a short character not in the long option.

  cooloptions.after do |result|                             # Gets called with the result of the parse _before_ returning it.
    unless result.option == 'a'                             # Allows for easy validation of options.
      cooloptions.error("Invalid format.")    
    end
    result.name = ARGV.shift                                # Or grabbing additional arguments.
  end

  cooloptions.parser.on('-z', '--raw [STUFF]', String,      # If you want to do funky optparse stuff, you can use the parser.
                        'Raw optparse.') do |option|        # However, if you're doing more of this than of the simple stuff,
                          puts "RAW!"                       # you should consider just using optparse directly.
                        end
end

p options.option    # All the options get put in to an OpenStruct keyed by their long name (with '-' becoming '_')
