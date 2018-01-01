require 'chunky_png'

fname = ARGV[0]

png = ChunkyPNG::Image.from_datastream( ChunkyPNG::Datastream.from_file( fname + ".png" ) )

html = File.new( fname + ".html", "w+" )
css  = File.new( fname + ".css", "w+" )

colours = {}

png.palette.each_with_index do |pt, i|
  if pt > 0
    cid = "c#{i}"
    hex = ChunkyPNG::Color.to_hex( pt, false )
    css.write ".#{cid} {\n  background-color: #{hex};\n}\n\n"
    colours[hex] = "#{cid}"
  end
end

runes = ['k', 'l', 'i', 'o', 't']
ridx = 0

rune_w = 7
rune_h = 11
rune_space = 2
@rune_start_l = 7
@rune_start_t = 26

@max_rune_w = @rune_start_l + rune_w - 1
@max_rune_h = @rune_start_t + runes.size * ( rune_h + rune_space ) - rune_space

rune_active = false
rune_hex = "#180018"

html_str = ""

def rune_row?( r )
  return r.between?( @rune_start_t, @max_rune_h ) \
      && ((r - @rune_start_t) % 13) <= 10
end

def rune_col?( c )
  return c.between?( @rune_start_l, @max_rune_w )
end

def is_rune?( r, c )
  return rune_col?( c ) && rune_row?( r )
end

for r in 0...png.height
  row = png.row r
  html_str += "<!-- row#{r} -->\n"

  if !rune_row?( r ) && rune_row?( r - 1 )
    ridx += 1
  end

  for c in 0...row.size
    hex = ChunkyPNG::Color.to_hex( row[c], false )

    rune_active = is_rune? r, c

    if colours[hex]
      html_str += "<px class=\"#{colours[hex]}" \
                + (hex == rune_hex ? " rune" : '') \
                + (rune_active ? " link\" data-rune=\"#{runes[ridx]}" : '') \
                + "\"></px>\n"
    else
      html_str += "<px class=\"px inv\"></px>\n"
    end
  end
end

html.write html_str

colours.each_pair { |name, val| p "#{name} => #{val}"  }
