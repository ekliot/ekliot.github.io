require 'json'
require 'chunky_png'

# # # # #
# SETUP #
# # # # #

fname = ARGV[0]

png = ChunkyPNG::Image.from_datastream( ChunkyPNG::Datastream.from_file( fname + ".png" ) )

# html = File.new( "_includes/nav.html", "w+" )
# css  = File.new( "_sass/nav-colour.scss", "w+" )
json_out = File.new( "assets/scripts/nav_data.json", "w+" )

# # # # # # # # # #
# READ IN COLOURS #
# # # # # # # # # #

# @colours = {}
#
# # for each colour of the png's palette
# png.palette.each_with_index do |pt, i|
#   # if the colour isn't transparent
#   if pt > 0
#     # give it an ID of the i-th colour
#     cid = "c#{i}"
#     # convert it to a hex value (for CSS)
#     hex = ChunkyPNG::Color.to_hex( pt, false )
#     # write its CSS class into the file
#     # css.write ".#{cid} {\n  background-color: #{hex};\n}\n\n"
#     # flag this colour in our index with its ID
#     @colours[hex] = "#{cid}"
#   end
# end

# # # # # # # # #
# RUNE VAR INIT #
# # # # # # # # #

# the runes we're expecting to find
@runes = [ :home, :projects, :log, :about, :contact ]
@ridx = 0

# properties of rune sizes and spacing
@_rune = {
  w: 7, # each rune is 7px wide
  h: 11, # and 11px tall
  space: 2, # with 2px between each
  start_x: 7, # the runes start at the 7th column
  start_y: 26, # and at the 26th row
  active: false, # flag for whether a rune is being traversed
  hex: "#2d2d37" # colour of the runes
}

# runes will not appear beyond this column
@_rune[:max_x] = @_rune[:start_x] + @_rune[:w] - 1
# nor beyond this row
@_rune[:max_y] = @_rune[:start_y] + @runes.size * ( @_rune[:h] + @_rune[:space] ) - @_rune[:space]

# # # # # # # # # #
# LABEL VAR INIT  #
# # # # # # # # # #

# properties of label sizes and spacing
@_label = {
  w: [ 19, 19, 14, 11, 14 ],
  h: 7,
  space: 6,
  start_x: 31,
  start_y: 28,
  active: false,
  hex: "#fafffa"
}

# labels will not appear beyond this row
@_label[:max_y] = @_label[:start_y] + @runes.size * ( @_label[:h] + @_label[:space] ) - @_label[:space]

@data_hash = {
  size: { w: 50, h: 98 },
  runes: {
    range: {
      min: { x: @_rune[:start_x], y: @_rune[:start_y] },
      max: { x: @_rune[:max_x],   y: @_rune[:max_y]   }
    },
    home: {
      range: {
        min: { x: @_rune[:start_x], y: @_rune[:start_y] + ( @_rune[:h] + @_rune[:space] ) * 0 },
        max: { x: @_rune[:start_x] + @_rune[:w], y: @_rune[:start_y] + @_rune[:h] * 1 + @_rune[:space] * 0 }
      },
      px: []
    },
    projects: {
      range: {
        min: { x: @_rune[:start_x], y: @_rune[:start_y] + ( @_rune[:h] + @_rune[:space] ) * 1 },
        max: { x: @_rune[:start_x] + @_rune[:w], y: @_rune[:start_y] + @_rune[:h] * 2 + @_rune[:space] * 1 }
      },
      px: []
    },
    log: {
      range: {
        min: { x: @_rune[:start_x], y: @_rune[:start_y] + ( @_rune[:h] + @_rune[:space] ) * 2 },
        max: { x: @_rune[:start_x] + @_rune[:w], y: @_rune[:start_y] + @_rune[:h] * 3 + @_rune[:space] * 2 }
      },
      px: []
    },
    about: {
      range: {
        min: { x: @_rune[:start_x], y: @_rune[:start_y] + ( @_rune[:h] + @_rune[:space] ) * 3 },
        max: { x: @_rune[:start_x] + @_rune[:w], y: @_rune[:start_y] + @_rune[:h] * 4 + @_rune[:space] * 3 }
      },
      px: []
    },
    contact: {
      range: {
        min: { x: @_rune[:start_x], y: @_rune[:start_y] + ( @_rune[:h] + @_rune[:space] ) * 4 },
        max: { x: @_rune[:start_x] + @_rune[:w], y: @_rune[:start_y] + @_rune[:h] * 5 + @_rune[:space] * 4 }
      },
      px: []
    }
  },
  labels: {
    range: {
      min: { x: @_label[:start_x], y: @_label[:start_y] },
      max: { y: @_label[:max_y] }
    },
    home: {
      w: @_label[:w][0],
      range: {
        min: { x: @_label[:start_x], y: @_label[:start_y] + ( @_label[:h] + @_label[:space] ) * 0 },
        max: { x: @_label[:start_x] + @_label[:w][0], y: @_label[:start_y] + @_label[:h] * 1 + @_label[:space] * 0 }
      },
      px: []
    },
    projects: {
      w: @_label[:w][1],
      range: {
        min: { x: @_label[:start_x], y: @_label[:start_y] + ( @_label[:h] + @_label[:space] ) * 1 },
        max: { x: @_label[:start_x] + @_label[:w][1], y: @_label[:start_y] + @_label[:h] * 2 + @_label[:space] * 1 }
      },
      px: []
    },
    log: {
      w: @_label[:w][2],
      range: {
        min: { x: @_label[:start_x], y: @_label[:start_y] + ( @_label[:h] + @_label[:space] ) * 2 },
        max: { x: @_label[:start_x] + @_label[:w][2], y: @_label[:start_y] + @_label[:h] * 3 + @_label[:space] * 2 }
      },
      px: []
    },
    about: {
      w: @_label[:w][3],
      range: {
        min: { x: @_label[:start_x], y: @_label[:start_y] + ( @_label[:h] + @_label[:space] ) * 3 },
        max: { x: @_label[:start_x] + @_label[:w][3], y: @_label[:start_y] + @_label[:h] * 4 + @_label[:space] * 3 }
      },
      px: []
    },
    contact: {
      w: @_label[:w][4],
      range: {
        min: { x: @_label[:start_x], y: @_label[:start_y] + ( @_label[:h] + @_label[:space] ) * 4 },
        max: { x: @_label[:start_x] + @_label[:w][4], y: @_label[:start_y] + @_label[:h] * 5 + @_label[:space] * 4 }
      },
      px: []
    }
  }
}

# # # # # # # # #
# RUNE HELPERS  #
# # # # # # # # #

# are we in a row where a rune is active?
def rune_row?( r )
  r.between?( @_rune[:start_y], @_rune[:max_y] ) \
    && ((r - @_rune[:start_y]) % 13) <= 10
end

# are we in a column where a rune is active?
def rune_col?( c )
  c.between?( @_rune[:start_x], @_rune[:max_x] )
end

# are we in a position where a rune is active?
def is_rune?( r, c )
  rune_col?( c ) && rune_row?( r )
end

# # # # # # # # #
# LABEL HELPERS #
# # # # # # # # #

def label_row?( r )
  idx = (r - @_label[:start_y]) % 13
  r.between?( @_label[:start_y], @_label[:max_y] ) \
    && idx <= 9
end

def label_col?( c )
  max_w = @_label[:start_x] + @_label[:w][@ridx]
  c.between?( @_label[:start_x], max_w )
end

def is_label?( r, c )
  label_col?( c ) && label_row?( r )
end

# # # # # # # # #
# JSON BUILDING #
# # # # # # # # #

# traverse the PNG
for r in 0...png.height
  # if the current row is not a rune, and the last one was
  if !rune_row?( r ) && rune_row?( r - 1 )
    # move the cursor to the next rune
    @ridx += 1
  end

  # only bother reading the rows with data we care about
  if @ridx < @runes.size
    row = png.row r

    cur_rune = @runes[@ridx]

    if rune_row?( r ) || label_row?( r )
      for c in 0...row.size
        # set rune flag
        @_rune[:active]  = @ridx < @runes.size && is_rune?( r, c )
        @_label[:active] = @ridx < @runes.size && is_label?( r, c )

        hex = ChunkyPNG::Color.to_hex( row[c], false )

        # if this px is in our colour table (i.e. it isn't invisible)
        if hex == @_label[:hex]
          @data_hash[:labels][cur_rune][:px] << { x: c, y: r }
        elsif @_rune[:active] && hex == @_rune[:hex]
          @data_hash[:runes][cur_rune][:px] << { x: c, y: r }
        end
      end
    end
  elsif @ridx == @runes.size
    break
  end
end

@data_hash[:labels].each do |k, v|
  if k != :range then v[:px].sort_by! { |px| px[:x] } end
end

@data_hash[:runes].each do |k, v|
  if k != :range then v[:px].sort_by! { |px| px[:x] } end
end

json_out << @data_hash.to_json
