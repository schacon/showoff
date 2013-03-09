# Parade Presentation Software

Parade is a Sinatra web app that reads serves up markdown files in a
presentation format. Parade can serve a directory or be configured to run with
a simple configuration file.

## Comparison Vs PowerPoint / Keynote

Parade is easily out-done by professional presentation software packages as
far as out-of-the-box style and design. However, there are benefits that
Parade has over presentational software:

### The Good

* Markdown backed data

    > This ultimately makes it easier to manage diffs when making changes,
    using the content in other documents, and quickly re-using portions of a
    presentation.

* Syntax Highlighting

    > Using GitHub flavored markdown, code fences will automatically be
    syntax highlighted making it incredibly easy to integrate code samples

* Code Execution

    > Slides are able to provide execution and show results for JavaScript,
    and Coffeescript live within the browser. Allowing for live
    demonstrations of code.

* Web

    > The system is simply a website which allows for a lot of possibilities

### The Ugly

* Lack of style

    > Most presentation packages are going to provide for you better templates

* Speed of Layout and Animation

    > Unless you're skills are great with CSS/Animations, you are likely going
    to have a harder time creating presentations with as much polish.

* Resizing

    > Currently the presentation system can change gradual sizes, but is not
    very capable of growing well to the full resolution of current presentation
    resolution.

# Installation and Usage

```bash
$ gem install parade
```

## Starting the Slide Show

```bash
$ parade
```

By default running parade with start a presentation from the current working
directory. It will find all markdown files, `**/*.md`, within the directory
and create a presentation out of them.

>  By default parade will split slides along lines that start with a single `#`


## Slide Show Commands

You can manage the presentation with the following keys:

> ### *space* or *cursor right*
>
> Advance to the next slide or advance the next incremental bullet point
or show the end result of the code execution.
>
> ### *shift-space* or *cursor left*
>
> Move to the previous slide
>
> ### *z* or *?*
>
> Toggle help
>
> ### *f*
>
> Toggle footer (which shows slide count of total slides, percentage)
>
> ### *d*
>
> Toggle DEBUG information
>
> ### *c* or *t*
>
> Toggle the display of the Table of Contents
>
> ### *p*
>
> Toggle pre-show


### Serving a specific directory

```bash
$ parade [directory]
```

This will start a presentation from the specified directory. Again, finding all
markdown files contained within the directories or sub-directories.

### Serving specific files

To include certain files, specify an order, duplicate slides, you will need to
define a `parade` file. Within that file, you may define specific files,
specific folders, and the order of the presentation.

```ruby
title "My Presentation"
slides "intro.md"
section "directory_name"
```

> **slides** and **section** are exactly the same, however you may choose to
  use one over the other depending of you are mentioning a specific file of
  slides or a directory which could contain another `parade` or be considered
  a section.

You can so define sub sections with a title and slides or additional sections.

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

Slides are simply markdown format. As stated previously, slides will be
separated along the `#`elements within your document.

### Separator: !SLIDE

Relying on the `#` as a separator is not always ideal. So you may alternatively
use the `!SLIDE` separator. This also provides you with the ability to define
additional metadata with your slides and presentation.

```markdown
!SLIDE

# My Presentation

!SLIDE bullets incremental transition=fade

# Bullet Points

* first point
* second point
* third point
```

> Using this separator will immediately override `#`, so you will have to
  insert `!SLIDE` separators in all places you would like cut your slides.

## Notes

You can define special notes that are shown in presenter mode.

> Presenter mode has been removed until it can be rebuilt

Add a line that starts with .notes:

```markdown
## Important Slide

* First Thing
* Second Things

.notes The reason that the second thing came about is because things changed.
```

> In this example, the HTML output will contain a `<p class='notes'>`
Toggle presenter notes with the `n` key while in the presentation.

> Presenter mode has been removed until it can be rebuilt

### Metadata

#### HTML IDs

```markdown
!SLIDE #slide-id-1
```

> In this example the id of the slide div would be set to `#slide-id-1`

You can define an ID that will be added to the slide's `div`. This id will be
set to any value prefaced with the `#` character.

#### Transitions

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

#### CSS Classes

```markdown
!SLIDE bullets incremental my-custom-css-class
```
> In this example, this will add custom css classes to the slide's `div` will
  display the following classes:
  `class='content bullets incremental my-custom-css-class'`. _Note:_ the content
  class is added by the default slide template.

All remaining single terms are added as css classes to the slide's `div`.

##### Defined Classes

Parade defines a number of special CSS classes:

> ### center
> centers images on a slide
>
> ### bullets
> sizes and separates bullets properly (fits up to 5, generally)
>
> ### columns
>
> creates columns for every `##` markdown element in your slides (up to 4)
>
> ### smbullets
> sizes and separates more bullets (smaller, closer together)
>
> ### subsection
> creates a different background for titles
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


# Presentation Customization

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
* merlot
* slate

### Customized Footer

The presentation has the following default footer:

```html
<div id="footer">
  <span id="slideInfo"></span>
  <span id="debugInfo"></span>
  <span id="notesInfo"></span>
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

## Loading Custom CSS and JavaScript

By default Parade will load most CSS and JavaScript it finds within the the
directory which parade was launched, the current working directory.

You may however also specify a single resource folder or multiple resource folders
which parade will load instead of the current working directory.

```ruby

title "My Presentation"

theme "hack"
resources "scripts"
resources "stylesheets"

section "Introduction" do
  slides "intro.md"
end

```

The following will look for a folder named *scripts* and a folder named
*stylesheets* relative to the current working directory and load all
the CSS and JavaScript files found within those directories.


## Custom JavaScript

To insert custom JavaScript into your presentation you can either place it into
a file (with extension .js) into the root directory of your presentation or you
can embed a *script* element directly into your slides. This JavaScript will
be executed—as usually—as soon as it is loaded.

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

This command helps start a new parade presentation by setting up the proper directory structure for you.  It takes the directory name you would like parade to create for you.

> ### Options
>
> dir:"directory_name" - the name of the directory you want to generate the
>   presentation (defaults to *presentation*)
>
> title:"Presentation Title" - the title of the presentation
>
> description:"Presentation Description" - a description of the presentation

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

I really want this to evolve into a dynamic presentation software server,
that gives the audience a lot of interaction into the presentation -
helping them decide dynamically what the content of the presentation is,
ask questions without interrupting the presenter, etc.  I want the audience
to be able to download a dynamically generated PDF of either the actual
talk that was given, or all the available slides, plus supplementary
material. And I want the presenter (me) to be able to push each
presentation to Heroku or GitHub pages for archiving super easily.


## Presenter Tools

* simple highlighting (highlight region of slide / click to highlight)
* timer (time left, percent done, percent time done)
* editing slides
* preview
* let you write on the slide with your mouse, madden-style via canvas

## Presentation Layout

* theme support
* squeeze-to-fit style
* simple animations (image from A to B)
* show a timer - elapsed / remaining
* perform simple animations of images moving between keyframes
* automatically resize text to fit screen [see Alex's shrink.js]

## Output Formats

* pdf with notes
* webpage
* let audience members download slides, code samples or other supplementary
  material

## Clean up

* More modularity with presentation filters and renderers to allow presenters
  to create custom ones for the particular slide show
* Modular approach to features
* Clean up Javascript

## Interaction

* questions / comments system
* audience vote-based presentation builder, results live view
* show audience questions / comments (twitter or direct)
* let audience members go back / catch up as you talk
* let audience members vote on sections (?)

## Platforms

* show synchronized, hidden notes on another browser (like an iphone)
* broadcast itself on Bonjour
