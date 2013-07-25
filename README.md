
![parade](lib/public/parade.png)

Parade is a slide presentation deck built with developers in mind.

You compose parade presentations in markdown files and these files are presented
as a small web-application. This allows you to quickly build technical
presentations within minutes within your text editor instead of the tedious
drag'n'drop and arrange you find in most presentation packages.

### Highlights

* Markdown backed data

    > This ultimately makes it easier to manage diffs when making changes,
    using the content in other documents, and quickly re-using portions of a
    presentation.

* Syntax Highlighting

    > Using GitHub flavored markdown, code fences will automatically be
    syntax highlighted, making it incredibly easy to integrate code samples.

* Code Execution

    > Slides are able to provide execution and show results for JavaScript
    and Coffeescript live within the browser. This allows for live
    demonstrations of code.

* Web

    > Slide presentations are basically websites -- they run in your browser
    from your desktop. This allows for a wide range of possibilities for
    customization and expandability.

* Basic Templating and Color Schemes

    > Several templates and color scheme options have been provided to help you
    get started. While Parade does not currently provide anything near the
    variety of many other presentation packages, it is well-suited for basic
    presentations.

### Lowlights

* Design Flexibility (pros and cons)

    > Unless you're skilled in CSS/Animations, you will likely have a harder
    time creating presentations with as much polish as other programs provide.
    However, this approach also makes Parade incredibly flexible if you do
    understand CSS/Animations.

* Resizing

    > Currently, the presentation system can change gradual sizes, but does not
    have true full screen mode.

# Installation and Usage

```bash
$ gem install parade
```

## Starting the Slide Show

```bash
$ parade
```

By default, running parade starts a presentation from the current working
directory. It finds all markdown files, `**/*.md`, within the directory
and creates a presentation out of them.

>  By default parade will split slides along lines that start with a single `#`


## Slide Show Commands

You can manage the presentation with the following keys:

> ### *space* or *cursor right* or *cursor down*
>
> Advance to the next slide or advance the next incremental bullet point
or show the end result of the code execution.
>
> ### *shift-space* or *cursor left* or *cursor up*
>
> Move to the previous slide
>
>
> ### *\`* (backtick)
>
> Launches a visor terminal within your presentation that allows you to go to
> a specific slide by number, name or partial match of the slide title:
> `goto 12`, `goto start`, `goto end`, `goto javascript`.
>
> ### *h* or *?*
>
> Toggle help
>
> ### *f*
>
> Toggle footer (which shows slide count of total slides, percentage)
>
> ### *c* or *t*
>
> Toggle the display of the Table of Contents
>
> ### Visit "http://localhost:9090/print"
>
> Visiting this URL will generate a single page presentation that is printable
>

### Serving a specific directory

```bash
$ parade [directory]
```

This will start a presentation from the specified directory, finding all
markdown files contained within the directories or sub-directories.

### Serving specific files

To include certain files, specify an order, or duplicate slides, you will need to
define a `parade` file. Within that file, you may define specific files,
specific folders, and the order of the presentation.

```ruby
title "My Presentation"
slides "intro.md"
section "directory_name"
```

> **slides** and **section** are exactly the same. However, you may choose to
  use one over the other depending on if you are mentioning a specific file of
  slides or a directory which could contain another `parade` or be considered
  a section.

You can also define sub-sections with a title and slides or additional sections.

```ruby

title "My Presentation"

section "Introduction" do
  slides "intro.md"
end

section "Code Samples" do
  slides "ruby"
  slides "javascript"
  section "coffeescript"
end
```

# Slide Format

## Slide Separators

### Separator: **#**

Slides are simply markdown format. Slides will be separated along
the `#`elements within your document.

### Separator: !SLIDE

Relying on the `#` as a separator is not always ideal. Alternatively, you can
use the `!SLIDE` separator.

```markdown
!SLIDE

# My Presentation

!SLIDE

# Bullet Points

* first point
* second point
* third point
```

> Using this separator will immediately override `#`, so you will have to
  insert `!SLIDE` separators in all places you would like cut your slides.

## Notes

You can define special notes to your markdown which will not be displayed in
the final presentation to the user.

Add a line that starts with .notes:

```markdown
## Important Slide

* First Thing
* Second Things

.notes The reason that the second thing came about is because things changed.
```


# Presentation Customization

There are many ways you are able to customize your presentation.

## Themes

Parade comes with a set of themes which can be enabled in your **parade** file:

```ruby

title "My Presentation"

theme "hack"

section "Introduction" do
  slides "intro.md"
end

```

### Available Themes

* archetect
* hack
* hayfield
* merlot
* minimal
* slate


## Slide Layout

Parade supports various slide formats. These can be specified alongside the
slide separators. By adding a slide format, it adds a special CSS class to the
slide that is rendered. You may also specify custom CSS classes and an Id.

### HTML IDs

```markdown
!SLIDE #slide-id-1
```

> In this example the id of the slide div would be set to `#slide-id-1`

You can define an ID that will be added to the slide's `div`. This id will be
set to any value prefaced with the `#` character.

### CSS Classes

```markdown
!SLIDE bullets incremental my-custom-css-class
```
> In this example, this will add css classes to the slide's `div` and will
  display the following classes:
  `class='content bullets incremental my-custom-css-class'`.

#### Defined Classes

Parade defines a number of common slide formats:

> ### title
> places the content closer to the center of the page
>
> ### center
> centers images on a slide
>
> ### title-and-content
> places the title at the top and the content is left-aligned below it.
>
> ### section-header
> similar to a `title` class except it is a litle further down the page.
>
> ### bullets
> sizes and separates bullets properly (fits up to 5, generally)
>
> ### columns / comparison
>
> creates columns for every `##` markdown element in your slides (up to 4)
>
> ### smbullets
> sizes and separates more bullets (smaller, closer together)
>
> ### command
> monospaces h1 title slides
>
> ### commandline
> for pasted commandline sections (needs leading '$' for commands, then
> output on subsequent lines)
>
> ### incremental
> can be used with 'bullets' and 'commandline' styles, will incrementally
>  update elements on arrow key rather than switch slides
>
> ### text-size-(percentage)
> make all slide text size from 70% up to 150%, by percent increments of
> ten. E.G.: text-size-150, text-size-120, text-size-90, text-size-70.
>
> ### execute
> on Javascript and Coffeescript highlighted code slides, you can
> click on the code to execute it and display the results on the slide
>
> ### blank
> a slide without content is removed from the presentation unless you specify
> that the slide is blank.


#### Loading Custom CSS

By default Parade will load most CSS it finds within the the
directory which parade was launched; the current working directory.

You may however also specify a single resource folder or multiple resource folders
which parade will load instead of the current working directory.

```ruby

title "My Presentation"

theme "hack"
resources "stylesheets"

section "Introduction" do
  slides "intro.md"
end

```

The following will look for a folder named *stylesheets* relative to the current
working directory and load all the CSS files found within the directory.


### Customized Footer

The presentation has the following default footer:

```html
<div id="footer">
  <span id="slideInfo"></span>
  <span id="debugInfo"></span>
</div>
```

You can override the default footer of the presentation by specifying a file path to a customized footer.

```ruby
title "My Presentation"

footer "custom_footer.erb"

section "Introduction" do
  slides "intro.md"
end
```

This example will load a file named `customer_footer.erb` within your presentation directory.


## Slide Transitions

What is a presentation without slide transitions. Parade supports a variety
for slide transitions that can be specified alongside the side separator.

```markdown
!SLIDE transition=fade
```

> In this example, the slide will __fade__ when it is viewed. This will set
  `data-transition='fade'` on the slides's `div`.

You can define transitions from the available body of transitions.

The transitions are provided by jQuery Cycle plugin. See http://www.malsup.com/jquery/cycle/browser.html to view the effects and http://www.malsup.com/jquery/cycle/adv2.html for how to add custom effects.

##### Available Transitions

* none (this is the default)
* blindX, blindY, blindZ
* cover
* curtainX, curtainY
* fade
* fadeZoom
* growX, growY
* scrollUp, scrollDown, scrollLeft, scrollRight
* scrollHorz, scrollVert
* shuffle
* slideX, slideY
* toss
* turnUp, turnDown, turnLeft, turnRight
* uncover
* wipe
* zoom


## Loading Custom JavaScript

By default Parade will load most JavaScript it finds within the the
directory which parade was launched, the current working directory.

You may however also specify a single resource folder or multiple resource folders
which parade will load instead of the current working directory.

```ruby

title "My Presentation"

theme "hack"
resources "scripts"

section "Introduction" do
  slides "intro.md"
end

```

The following will look for a folder named *scripts* and a folder named
*stylesheets* relative to the current working directory and load all
the JavaScript files found within those directories.


### Custom JavaScript

To insert custom JavaScript into your presentation you can either place it into
a file (with extension .js) into the root directory of your presentation or you
can embed a *script* element directly into your slides. This JavaScript will
be executed as soon as it is loaded.

If you want to trigger some JavaScript as soon as a certain page is shown or
when you switch to the next or previous slide, you can bind a callback to a
custom event:

### Appearance

* parade:willAppear

> triggered before the slide is presented

* parade:didAppear

> triggered after the slide is presented

* parade:show

### Disappearance

> triggered after the slide is presented

* parade:willDisappear

> triggered before the slide disappears

* parade:didDisappear

> triggered after the slide disppeared

### Navigation

* parade:next

> triggered when an attempt to move to the next slide or incremental bullet point

* parade:prev

> triggered when an attempt to move back a slide or incremental bullet point


These events are triggered on the "div.content" child of the slide, so you must
add a custom and unique class to your SLIDE to identify it:

```markdown
!SLIDE custom_and_unique_class
# 1st Example h1
<script>
// bind to custom event
$(".custom_and_unique_class").live("parade:show", function (event) {
  // animate the h1
  var h1 = $(event.target).find("h1");
  h1.delay(500)
    .slideUp(300, function () { $(this).css({textDecoration: "line-through"}); })
    .slideDown(300);

    return false;
});
</script>
```

This will bind an event handler for *parade:show* to your slide. The
h1-element will be animated, as soon as this event is triggered on that slide.

If you bind an event handler to the custom events *parade:next* or
*parade:prev*, you can prevent the default action (that is switching to the
appropriate slide) by returning *false*:

```markdown
!SLIDE prevent_default
# 2nd Example h1
<script>
$(".prevent_default").live("parade:next", function (event) {
  var h1 = $(event.target).find("h1");
  if (h1.css("text-decoration") === "none") {
    h1.css({textDecoration: "line-through"})
    return false;
  }
});
</script>
```

This will bind an event handler for *parade:next* to your slide. When you press
the right arrow key the first time, the h1-element will be decorated. When you
press the right arrow key another time, you will switch to the next slide.

The same applies to the *parade:prev* event, of course.

## Custom Stylesheets

To insert custom Stylesheets into your presentation you can either place it into
a file (with extension .css) into the root directory of your presentation or
you can embed a *link* element directly into your slides. This stylesheet will
be applied as soon as it is loaded.

The content generated by the slide is wrapped with a *div* with the class .+content+ like this.

```html
<div class="content">
<h1>jQuery &amp; Sinatra</h1>
<h2>A Classy Combination</h2>
</div>
```

This makes the .*content* tag a perfect place to add additional styling if that
is your preference. An example of adding some styling is here.

```css
.content {
  color: black;
  font-family: helvetica, arial;
}
h1, h2 {
  color: rgb(79, 180, 226);
  font-family: Georgia;
}
.content::after {
  position: absolute;
  right: 120px;
  bottom: 120px;
  content: url(jay_small.png);
}
```

Note that the example above uses CSS3 styling with ::*after* and the *content*
-attribute to add an image to the slides.


# Command Line Interface

```bash
parade command_name [command-specific options] [--] arguments...
```

* Use the command __help__ to get a summary of commands
* Use the command `help command_name` to get a help for _command_name_
* Use `--` to stop command line argument processing; useful if your arguments have dashes in them

## parade help [command]

Shows list of commands or help for one command

## parade generate presentation

Create new parade presentation

This command helps start a new parade presentation by setting up the proper directory structure for you.  It takes the directory name you would like Parade to create for you.

> ### Options
>
> dir:"directory_name" - the name of the directory you want to generate the
>   presentation (defaults to *presentation*)
>
> title:"Presentation Title" - the title of the presentation
>
> description:"Presentation Description" - a description of the presentation

#### Example
```parade gen presentation dir:dir_name title:"My preso"
description:"Descrip"```

## parade generate outline

Create new parade outline file

Within the existing directory create a **parade** file that contains some
sample sections and slide references to get you started with creating
your customized presentation.

> ### Options
>
> title:"Presentation Title" - the title of the presentation
>
> description:"Presentation Description" - a description of the presentation
>
> outline:"custom outline filename" - if you want to specify a custom outline
>   filename (i.e. override the default **parade** filename).

## parade generate rackup

Create new rackup file

Within the existing directory create a **config.ru** file that contains the
default code necessary to serve this code on Heroku and other destinations.

## parade server

Serves the parade presentation in the current directory

> ### Options
>
> These options are specified *after* the command.
>
> *-f, --file=arg* Presentation file (default: *parade*)
>
> *-h, --host=arg* Host or IP to serve on (default *localhost*)
>
> *-p, --port=arg* The port to serve one (default: *9090*)
>
> ### Aliases
>
> parade s
>
> parade serve

## parade static html [path/to/parade/file]

Generates a static html representation of the presentation.

> ### Options
>
> These options are specified *after* the command.
>
> *-o, --output=file* Presentation output file

## parade static pdf [path/to/parade/file]

Generates a pdf representation of the presentation.

> ### Options
>
> These options are specified *after* the command.
>
> *-o, --output=file* Presentation output file

# Future Plans

## Presenter Tools

* Elapsed / Remaining Timer
* Drawing mode over the slides (Madden-style via canvas)
* Highlighting (highlight region of slide / click to highlight)

## Presentation Layout

* More Themes
* Key-Frame Animations
* Better slide resizing

## Interaction

* questions / comments system
* audience vote-based presentation builder, results live view
* show audience questions / comments (twitter or direct)
* let audience members vote on sections (?)
