!SLIDE subsection

# Subsection Slide #

!SLIDE

# Code Slide #

	@@@ ruby
	require 'sinatra/base'

	class MyApp < Sinatra::Base
	  set :sessions, true
	  set :foo, 'bar'

	  get '/' do
	    'Hello world!'
	  end
	end	

!SLIDE

    @@@ erlang
        Output = process(Input, []).

        process([First|Rest], Output) ->
            NewFirst = do_stuff(First),
            process(Rest, [NewFirst|Output]);

        process([], Output) ->
            lists:reverse(Output).

!SLIDE execute

# Executable JavaScript #

	@@@ javascript
	result = 3 + 3;

!SLIDE execute

# Executable Ruby #

	@@@ ruby
	result = [1, 2, 3].map { |n| n*7 }

!SLIDE

# Write your own slides #

## Using [markdown](http://daringfireball.net/projects/markdown/)

    !SLIDE
    
    # Title of the slide #
    
    How easy is this?

!SLIDE

# Using MathJax in your slides #

* Linked to MathJax server.
* Math display mode: \\[A_1\cap A_2\cap \cdots\cap A_k = \emptyset\\]
* Inline math looks like \\(B_i + A_k = \frac{1}{\sum_{x\in C}{S(x)}}\\), which is nice.
* Some caveats:
  * You may need to backslash escape underscores (since Markdown interprets them as emphasis delimiters).
  * You may need spaces around carats: \\(x ^ 2\\).
