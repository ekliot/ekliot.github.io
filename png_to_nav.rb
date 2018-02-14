require 'chunky_png'

# # # # #
# SETUP #
# # # # #

fname = ARGV[0]

png = ChunkyPNG::Image.from_datastream( ChunkyPNG::Datastream.from_file( fname + ".png" ) )

html = File.new( "_includes/nav.html", "w+" )
# css  = File.new( "_sass/nav-colour.scss", "w+" )

# # # # # # # # # #
# READ IN COLOURS #
# # # # # # # # # #

@colours = {}

# for each colour of the png's palette
png.palette.each_with_index do |pt, i|
  # if the colour isn't transparent
  if pt > 0
    # give it an ID of the i-th colour
    cid = "c#{i}"
    # convert it to a hex value (for CSS)
    hex = ChunkyPNG::Color.to_hex( pt, false )
    # write its CSS class into the file
    # css.write ".#{cid} {\n  background-color: #{hex};\n}\n\n"
    # flag this colour in our index with its ID
    @colours[hex] = "#{cid}"
  end
end

# # # # # # # # #
# RUNE VAR INIT #
# # # # # # # # #

# the runes we're expecting to find
@runes = [
  ['k', "home", "/"],
  ['l', "projects", "/projects"],
  ['i', "log", "/log"],
  ['o', "about", "/about"],
  ['t', "contact", "/contact"],
]
@ridx = 0

# properties of rune sizes and spacing
rune_w = 7 # each rune is 7px wide
rune_h = 11 # and 11px tall
rune_space = 2 # with 2px between each
@rune_start_l = 7 # the runes start at the 7th column
@rune_start_t = 26 # and at the 26th row

# runes will not appear beyond this column
@max_rune_w = @rune_start_l + rune_w - 1
# nor beyond this row
@max_rune_h = @rune_start_t + @runes.size * ( rune_h + rune_space ) - rune_space

# initialize flag for whether a rune is being traversed
@rune_active = false
# and the actual colour of the runes
@rune_hex = "#2d2d37"

label_h = 9
@label_w = [ 25, 25, 20, 17, 22]
label_space = 4
@label_start_l = 30
@label_start_t = 27

# labels will not appear beyond this row
@max_label_h = @label_start_t + @runes.size * ( label_h + label_space ) - label_space

# initialize flag for whether a label is being traversed
@label_active = false

html_str = ""

# # # # # # # # #
# RUNE HELPERS  #
# # # # # # # # #

# are we in a row where a rune is active?
def rune_row?( r )
  r.between?( @rune_start_t, @max_rune_h ) \
    && ((r - @rune_start_t) % 13) <= 10
end

# are we in a column where a rune is active?
def rune_col?( c )
  c.between?( @rune_start_l, @max_rune_w )
end

# are we in a position where a rune is active?
def is_rune?( r, c )
  rune_col?( c ) && rune_row?( r )
end

# # # # # # # # #
# LABEL HELPERS #
# # # # # # # # #

def label_row?( r )
  idx = (r - @label_start_t) % 13
  r.between?( @label_start_t, @max_label_h ) \
    && idx <= 9
end

def label_col?( c )
  max_w = @label_start_l + @label_w[@ridx]
  c.between?( @label_start_l, max_w )
end

def is_label?( r, c )
  label_col?( c ) && label_row?( r )
end

# # # # # # # # #
# HTML BUILDING #
# # # # # # # # #

def liquid_root_check( rune_data )
  root = rune_data[1]
  type = "rune" + if @label_active then "-label" else "" end
  "{% if root==\"#{root}\" %} active{% endif %} #{type}"
end

def make_px( hex )
  rune_data = @runes[@ridx]
  if @rune_active
    "<a class=\"px #{@colours[hex]}#{liquid_root_check( rune_data ) if hex == @rune_hex}\" href=\"#{rune_data[2]}\" data-rune=\"#{rune_data[0]}\"></a>"
  elsif @label_active
    "<a class=\"px #{@colours[hex]}#{liquid_root_check( rune_data )}\" href=\"#{rune_data[2]}\" data-label=\"#{rune_data[0]}\"></a>"
  else
    "<div class=\"px #{@colours[hex]}\"></div>"
  end
end

html_str += "{% assign root=include.root %}\n<div id=\"Nav\">\n"

# traverse the PNG
for r in 0...png.height
  row = png.row r
  html_str += "    <!-- row#{r} -->\n    "

  # if the current row is not a rune, and the last one was
  if !rune_row?( r ) && rune_row?( r - 1 )
    # move the cursor to the next rune
    @ridx += 1
  end

  for c in 0...row.size
    hex = ChunkyPNG::Color.to_hex( row[c], false )

    # set rune flag
    @rune_active = @ridx < @runes.size && is_rune?( r, c )
    @label_active = @ridx < @runes.size && is_label?( r, c )

    # if this px is in our colour table (i.e. it isn't invisible)
    if @colours[hex] || @label_active
      # make a px element for it
      html_str += make_px hex
    else
      # otherwise, just add an invisible pixel
      html_str += "<div class=\"px inv\"></div>"
    end
  end

  html_str += "\n"
end

html.write html_str + "</div>\n"

# # # # # # # # # # # #
# EXTRA DEBUG OUTPUT  #
# # # # # # # # # # # #

@colours.each_pair { |name, val| p "#{name} => #{val}"  }
