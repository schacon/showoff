!SLIDE

# Slide Classes

!SLIDE center

## center

![octocat](../images/octocat.png)

centers images on a slide

!SLIDE

```
    !SLIDE center

    ## center

    ![octocat](../images/octocat.png) 
```

!SLIDE center full-page

## center full-page

![octocat](../images/octocat.png)

!SLIDE columns

# Columns

## One Column

The content will space the length of the entire slide.

!SLIDE columns

# Columns

## Markdown

All content is written and managed in markdown

## Code

```ruby
class Parade
end
```

!SLIDE columns

# Columns

## Markdown

All content is written and managed in markdown

## Code

```ruby
class Parade
end
```

## Execution

> Code will execute live


!SLIDE columns

# Columns

## Markdown

All content is written and managed in markdown

## Code

```ruby
class Parade
end
```

## Execution

> Code will execute live


## Powered

* Ruby
* Javascript
* CSS

!SLIDE bullets

## bullets

* One
* Two
* Three
* Four
* Five

sizes and separates bullets properly (fits up to 5, generally)

!SLIDE smbullets

## smbullets

* One
* Two
* Three
* Four
* Five

sizes and separates more bullets (smaller, closer together)

!SLIDE subsection

## subsection

# titles

creates a different background for titles

!SLIDE command

## command

monospaces h1 title slides

!SLIDE commandline

## commandline

```bash
$ command
response
```

for pasted commandline sections (needs leading '$' for commands, then
output on subsequent lines)

!SLIDE incremental bullets

## incremental bullets

* one
* two
* three

!SLIDE incremental commandline

## incremental commandline

```bash
$ command
response
```

!SLIDE text-size-150

## text-size-150

make all slide text 150% (largest value)

!SLIDE text-size-70

## text-size-70

make all slide text 70% (smallest value)

!SLIDE

## text-size-(percentage)

note that you may feel free to increment text size by 10 percent
from 70 to 150. the current slide is set to the standard font size.

!SLIDE execute

## execute

```javascript
result = 1 + 1;
```

> Supports Javascript, Coffeescript and Ruby highlighted code slides, you can
click on the code to execute it and display the results on the slide