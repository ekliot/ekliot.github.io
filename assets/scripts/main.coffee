# ---
# ---

# sleep for specified # of ms
sleep = ( ms ) ->
  new Promise ( resolve ) ->
    window.setTimeout resolve, ms

rand_int = ( min, max ) ->
  Math.floor( Math.random() * ( max - min ) ) + min

# randomly shuffle an array
shuffle = (a) ->
  i = a.length
  while --i > 0
    j = ~~(Math.random() * (i + 1))
    t = a[j]
    a[j] = a[i]
    a[i] = t
  a


window.onload = () ->
  canv = $( "#Nav" )[0]
  if canv.getContext
    $.getJSON '/assets/scripts/nav_data.json', ( data ) ->
      bgcolor = $( "#Container" ).css( "background-color" )
      nav = new Nav(
        canv, data, bgcolor,
        canv.dataset.root
      )
  name = "ekliot"
  mail = "gmail.com"
  if document.getElementById( "NoJS" )
    document.getElementById( "NoJS" ).innerHTML = " at <a href =\"mailto:#{name}@#{mail}\">#{name}@#{mail}</a>"














# coverup = () ->
  # nav_bar = document.getElementById "Nav"
  #
  # start = new Date().getTime()
  # px_arr = [].slice.call( document.getElementsByClassName "rune-label" ).filter (px) ->
  #   ![].slice.call( px.classList ).includes "active"
  # px.classList.add( "invisible" ) for px in px_arr
  # end = new Date().getTime()
  # console.log start
  # console.log end
  # console.log end-start
  #
  # console.log px_arr.length
  #
  # for r in [0...row_cnt]
  #   start_idx = r * row_size
  #   px_arr[start_idx...start_idx+row_size] = shuffle px_arr[start_idx...start_idx+row_size]
  #
  # for r in [1...row_cnt/2]
  #   start_idx = r * 2 * row_size
  #   max = start_idx + row_size
  #   max = px_arr.length if max >= px_arr.length
  #   px_arr[start_idx...max] = shuffle px_arr[start_idx...max]
  #
  # steps = 100
  # chunk = px_arr.length // steps
  # set = chunk
  #
  # console.log steps, chunk, set
  #
  # for i in [0...steps+10]
  #   start_idx = i * chunk
  #   for j in [start_idx...start_idx+chunk] by set
  #     px.classList.remove( "invisible" ) for px in px_arr[j...j+set]
  #     # await sleep( 1 )
  #   await sleep( 100 - i )
  #
  # covered = true

# window.onload = () ->
  # coverup()
  # until covered
  #   await sleep( 50 )
  # cell_cnt = squares.length * squares[0].length
  # reveal 1

# window.onresize = () ->
#   if covered and not revealing then resize_cover()
