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

for r in 0...png.height
  row = png.row r
  html.write "<!-- row#{r} -->\n"
  for c in 0...row.size
    # px = png.get_pixel( r, c )
    px = row[c]

    hex = ChunkyPNG::Color.to_hex( px, false )

    if colours[hex]
      html.write "<div class=\"px #{colours[hex]}\"></div>\n"
    else
      html.write "<div class=\"px inv\"></div>\n"
    end
  end
end

colours.each_pair { |name, val| p "#{name} => #{val}"  }
