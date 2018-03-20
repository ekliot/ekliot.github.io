class Nav
  constructor: ( canv, data, bgcolor, root ) ->
    @canv = canv
    @data = data
    @bgcolor = bgcolor
    @root = root

    @mousover = null
    @ratio = @canv.width / @canv.height
    @orig_dim = { w: data.size.w, h: data.size.h }
    @curr_dim = { w: data.size.w, h: data.size.h }
    @active = getComputedStyle( @canv ).display != "none"

    @ani = {
      active: false,
      states: {
        home:     0,
        projects: 0,
        log:      0,
        about:    0,
        contact:  0
      },
      steps: { # the first int is index of animation
        # these are px values for each step of the cover animation
        home:     [ (root is 'home') * 38,     1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 ],
        projects: [ (root is 'projects') * 38, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 ],
        log:      [ (root is 'log') * 28,      1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 ],
        about:    [ (root is 'about') * 22,    1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 ],
        contact:  [ (root is 'contact') * 28,  1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 ]
        # home:     [ (root is 'home') * 4,     5, 5, 5, 4 ],
        # projects: [ (root is 'projects') * 4, 5, 5, 5, 4 ],
        # log:      [ (root is 'log') * 3,      5, 5, 4 ],
        # about:    [ (root is 'about') * 3,    5, 2, 4 ],
        # contact:  [ (root is 'contact') * 3,  5, 5, 4 ]
      }
    }

    img_src = "/assets/media/images/sword-nav.png"

    # load initial image
    @img = new Image()
    @img.onload = () =>
      @load_img()
    @img.src = img_src

    @scale()

    # set mouse listeners
    @canv.addEventListener 'mousemove', @mouseover_check
    @canv.addEventListener 'click',     @mouseclick_check

    # set resize listener
    window.addEventListener 'resize', () =>
      @active = getComputedStyle( @canv ).display != "none"
      if @active and @canv.parentNode.offsetWidth != @curr_dim.w
        console.log "Aasbd"
        @scale()

  scale: () ->
    @canv.width  = @curr_dim.w = @canv.parentNode.offsetWidth
    @canv.height = @curr_dim.h = @curr_dim.w / @ratio

    ctx = @canv.getContext '2d'

    ctx.imageSmoothingEnabled       = false
    ctx.mozImageSmoothingEnabled    = false
    ctx.webkitImageSmoothingEnabled = false
    ctx.msImageSmoothingEnabled     = false

    @load_img()

  ###
    ANIMATION WALKTHROUGH

    store current cover sizes (in width) for each label
      - the bounds are [0, @data.labels.$label.w]
      - do not include the root label

    also store the animation states for each
      -  1: reduce clearRect size
      -  0: keep size
      - -1: increase clearRect size

    size-delta is equal to get_scaling() in px

    steps:
      - save frame with sword
      - while all states are not 0:
        - increase/decrease each cover by delta based on animation state
        - if that cover hits a terminal size, set state to 0
      - when mouse enters a label/rune, set its state to 1
      - when mouse leaves a label/rune, set its state to -1

  ###

  check_to_ani: () ->
    to_ani = false

    for label, state of @ani.states
      to_ani = to_ani or state != 0

    to_ani

  update_ani_states: () ->
    for label, steps of @ani.steps
      state = @ani.states[label]
      switch state
        when -1
          if steps[0] > 0
            steps[0] = steps[0] + state
          else
            @ani.states[label] = 0
        when 1
          if steps[0] + 1 < steps.length
            steps[0] = steps[0] + state
          else
            @ani.states[label] = 0

  draw: () =>
    @ani.active = @check_to_ani()
    if not @ani.active then return

    @update_ani_states()

    @load_img() # this will render a new canvas with

    window.requestAnimationFrame( @draw )

  load_img: () ->
    # how much should we scale the pixel art?
    scale = @get_scaling()
    @canv.getContext( '2d' ).drawImage(
      @img, 0, 0, # source and (x,y) pos
      scale * @orig_dim.w, # width
      scale * @orig_dim.h  # height
    )
    @load_coverup() # make the label coverups
    @color_runes()

  #
  load_coverup: () ->
    for label, data of @data.labels
      if label != "range" and label != @root
        r = data.range
        steps = @ani.steps[label]
        shrink_by = if steps[0] then steps[1..steps[0]].reduce (a, b) -> a + b else 0

        y = r.min.y
        w = r.max.x - r.min.x - shrink_by
        x = r.min.x + shrink_by
        h = r.max.y - y

        @draw_coverup( x, y, w, h )

  # draw a rectangle of ( size, size ) at ( x, y ) of the background color
  draw_coverup: ( x, y, w, h ) ->
    sc = @get_scaling()
    ctx = @canv.getContext '2d'
    ctx.fillStyle = @bgcolor
    ctx.fillRect( x * sc, y * sc, w * sc, h * sc )

  color_runes: () ->
    sc = @get_scaling()
    ctx = @canv.getContext '2d'
    ctx.fillStyle = 'red'

    for px in @data.runes[@root].px
      ctx.fillRect( px.x * sc, px.y * sc, sc, sc )
    if @mouseover then for px in @data.runes[@mouseover].px
      ctx.fillRect( px.x * sc, px.y * sc, sc, sc )

  mouseover_check: ( ev ) =>
    x = y = 0
    crect = @canv.getBoundingClientRect()

    x = ev.clientX - crect.left
    y = ev.clientY - crect.top

    sc = @get_scaling()
    rune_range = @data.runes.range
    label_range = @data.labels.range

    @mouseover = @mouseover_rune x, y, sc
    # console.log @mouseover
    @mouseover = if @mouseover then @mouseover else @mouseover_label x, y, sc
    # console.log @mouseover

    if @mouseover
      @canv.style.cursor = "pointer"
      if @mouseover != @root
        @ani.states[@mouseover] = 1
    else
      @canv.style.cursor = "default"

    for k, v of @ani.states
      if k != @root and k != @mouseover #and v != 0
        @ani.states[k] = -1

    @draw()

  # return the label that the mouse is over, or null if not
  mouseover_label: ( x, y, sc ) ->
    for label, data of @data.labels
      if label != 'range'
        r = data.range
        if x >= r.min.x * sc and x <= r.max.x * sc and y >= r.min.y * sc and y <= r.max.y * sc
          return label
    @canv.style.cursor = "default"
    return null

  # return the rune that the mouse is over, or null if not
  mouseover_rune: ( x, y, sc ) ->
    for rune, data of @data.runes
      # console.log rune, data
      if rune != 'range'
        r = data.range
        if x >= r.min.x * sc and x <= r.max.x * sc and y >= r.min.y * sc and y <= r.max.y * sc
          return rune
    @canv.style.cursor = "default"
    return null

  # handle mouseclick events based on where the mouse is hovering
  mouseclick_check: ( ev ) =>
    if @mouseover is "home"
      window.open( "/", "_self" )
    else if @mouseover
      window.open( "/#{@mouseover}", "_self" )

  # return the image scaling for pxel proportions
  get_scaling: () ->
    Math.floor @curr_dim.w / @orig_dim.w
