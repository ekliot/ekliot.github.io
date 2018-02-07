# ---
# ---

# sleep for specified # of ms
sleep = ( ms ) ->
  new Promise ( resolve ) ->
    window.setTimeout resolve, ms

rand_int = ( min, max ) ->
  Math.floor( Math.random() * ( max - min ) ) + min

covered = false
revealing = false

# how many cells per row
subdivs    = 50 # max 12, per responsivebp grid guidelines
# how many total cells exist
cell_cnt   = 0
# how many cells have been cleared
clear_cnt  = 0

# how many cells to clear per step
step_clear = 8
# initial delay between steps
step_delta = 1000 # ms
# how much to haste each step
step_accel = -1 # ms

squares = []

# dynamically builds and resizes the coverdiv according to window size

coverup = () ->
  container = document.getElementById( "Contents" ).parentNode
  container.innerHTML = "<div id=\"Coverup\"></div>" + container.innerHTML

  resize_cover()

  covered = true

# checks if the reveal animation has completed
all_clear = () ->
  return clear_cnt is cell_cnt

set_clear = ( idx ) ->
  coverdiv  = document.getElementById "Coverup"
  r = idx // subdivs
  c = idx % subdivs

  coverdiv.children[r].children[c].className += " hidecell"
  # coverdiv.children[r].children[c].style.opacity = 0
  squares[r][c] = false
  clear_cnt += 1

can_clear = ( idx ) ->
  r = idx // subdivs
  c = idx % subdivs
  return squares[r][c]

reveal = ( step ) ->
  revealing = true
  # console.log "reveal step #{step}"
  if not all_clear()
    # the cells to be cleared are within the first $range cells
    range = Math.min( step * subdivs, cell_cnt )
    # console.log "clearing #{step_clear} of the first #{range} cells"

    for cell in [1..step_clear]
      if all_clear() then break
      cand = rand_int( 0, range )
      until can_clear( cand )
        if cand is range-1
          cand = 0
        else
          cand += 1
      # console.log "clearing cell ##{cand}"
      set_clear( cand )

    delay = Math.min( step_delta + (step_accel * (step-1)), 20 )
    # console.log "delaying #{delay}ms"
    await sleep( delay )
    reveal( step + 1 )
  else
    revealing = false
    covered = false
    container = document.getElementById( "Coverup" ).parentNode
    setTimeout( (() -> container.removeChild( container.firstChild )), 1000 )

window.onload = () ->
  coverup()
  until covered
    await sleep( 50 )
  cell_cnt = squares.length * squares[0].length
  reveal 1

window.onresize = () ->
  if covered and not revealing then resize_cover()
