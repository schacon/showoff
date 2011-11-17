require 'parslet'

# For parsing commandline slide content.
class CommandlineParser < Parslet::Parser

  rule(:prompt) do
    str('$') | str('#') | str('>>')
  end

  rule(:text) do
    match['[:print:]'].repeat
  end

  rule(:singleline_input) do
    (str("\\\n").absent? >> match['[:print:]']).repeat
  end

  rule(:input) do
    multiline_input | singleline_input
  end

  rule(:multiline_input) do

    # some command \
    # continued \
    # \
    # and stop
    ( singleline_input >> str('\\') >> newline ).repeat(1) >> singleline_input
  end

  rule(:command) do

    # $ some command
    # some output
    ( prompt.as(:prompt) >> space? >> input.as(:input) >> output? ).as(:command)
  end

  rule(:output) do

    # output
    prompt.absent? >> text
  end

  rule(:output?) do

    #
    # some text
    # some text
    #
    # some text
    ( newline >> ( ( output >> newline ).repeat >> output.maybe ).as(:output) ).maybe
  end

  rule(:commands) do
    command.repeat
  end

  rule(:newline) do
    str("\n") | str("\r\n")
  end

  rule(:space?) do
    match['[:space:]'].repeat
  end

  root(:commands)
end
