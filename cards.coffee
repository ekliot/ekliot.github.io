class Card
  constructor: ( deck, id, title ) ->
    @deck = deck
    @id = id
    @div = document.getElementById "#{id}"
    @title = title
    @active = false

  toggle_active: () ->
    @active = !@active

  get_div: () ->
    document.getElementById "#{@id}"

  #
  # ANIMATION
  #

  swipe: ( dir='up' ) ->
    rem = parseFloat getComputedStyle( document.documentElement ).fontSize
    div = @get_div()
    top = if dir is 'up' then -120 else 120
    rot = if dir is 'up' then 10 else -10

    div.classList.add "swiped"
    div.style.top = "#{top}%"
    div.style.left = "-#{rem}"
    div.style.transform = "rotate(#{rot}deg)"
    div.style["-moz-transform"] = "rotate(#{rot}deg)"
    div.style["-webkit-transform"] = "rotate(#{rot}deg)"
    window.setTimeout( (
      () => @set_z( 0 )
    ), 500 )

  set_z: ( z ) ->
    div = @get_div()
    div.style["z-index"] = "0"
    div.style.transform = "rotate(0deg)"
    div.style["-moz-transform"] = "rotate(0deg)"
    div.style["-webkit-transform"] = "rotate(0deg)"

class Deck
  constructor: ( name, deck ) ->
    @name = name

    # Array of Cards
    @deck = []
    # HTMLElement <deck>
    @div = deck
    @size = 0
    @active = 0

    @build_deck()

  # add <card> elements of @div as Cards into the Card Array
  build_deck: () ->
    idx = 0
    for card in @div.children
      card.dataset.idx = idx
      @add_card( new Card @name, card.id, card.dataset.title )
      idx++

  add_card: ( card ) ->
    @deck.push card
    @size++

  get_active: () ->
    @deck[@active]

  set_active: ( idx, dir='def' ) ->
    if idx is @active then return
    last = @active
    @active = idx

    # dumb ifelse monstrosity...

    # if we are scrolling backwards...
    if last > @active
      # console.log 1
      for i in [last...@size]
        @deck[i].swipe( if dir is 'def' then 'up' else dir )
      # and, if the next active card is not the first card...
      if @active != 0
        # console.log 2
        for i in [0...@active]
          @deck[i].swipe( if dir is 'def' then 'up' else dir )
    # otherwise
    else
      # console.log 3
      for i in [last...@active]
        @deck[i].swipe( if dir is 'def' then 'up' else dir )

    window.setTimeout( (() =>
      @update_layout()
    ), 500 )

  next_card: () ->
    @set_active( (if @active is @size - 1 then 0 else @active + 1), 'up' )

  last_card: () ->
    @set_active( (if @active is 0 then @size - 1 else @active - 1), 'down' )

  enter: ( target ) ->
    for i in [@size-1..0] by -1
      target.appendChild( @deck[i].get_div() )
    # for some reason, the animations don't work unless we set it up in a timeout
    window.setTimeout( (() => @update_layout()), 0 )

  exit: () ->
    for card in @deck
      card.get_div().style = ""
      card.get_div().classList.remove "inactive"

    window.setTimeout( (() =>
      for card in @deck
        @div.appendChild card.get_div()
    ), 500 )

    # return

  update_layout: () ->
    rem = parseFloat getComputedStyle( document.documentElement ).fontSize
    draw_cnt = 1

    # draw the cards from back to front
    for i in [@active-1..0] by -1
      card = @deck[i].get_div()
      card.style["z-index"] = "#{draw_cnt}"
      card.style.left = "#{(@size - draw_cnt) * rem}px"
      card.style.top = "-#{(@size - draw_cnt) * rem}px"

      card.classList.add( "inactive" )

      draw_cnt += 1

    for i in [@size-1..@active] by -1
      card = @deck[i].get_div()
      card.style["z-index"] = "#{draw_cnt}"
      card.style.left = "#{(@size - draw_cnt) * rem}px"
      card.style.top = "-#{(@size - draw_cnt) * rem}px"

      if i != @active
        card.classList.add( "inactive" )
      else
        card.classList.remove( "inactive" )

      draw_cnt += 1

class Board
  constructor: ( targ, idx ) ->
    # HTMLElement <hand>
    @targ = targ

    # HTMLElement <index>
    @idx = idx
    # HTMLElement <ul>
    @guide = idx.querySelector 'guide'
    # HTMLElement <a>
    @logo  = idx.querySelector '#E'

    # Deck.name -> Deck
    @decks = {}
    # Deck
    @active = null

    @title = "Elijah Kliot"

    # scroll control
    @scroll_stamp = new Date().getTime()
    @scroll_buff = 0
    @scroll_delay = 500
    @scroll_thresh = 5

  init: () ->
    @scale()

    # set resize listener
    window.addEventListener 'resize', (() => if @active? then @scale()), true

    # set scroll listener
    window.addEventListener 'wheel', @parse_scroll, false

    # set listeners for each card
    for card in document.querySelectorAll 'card'
      card.addEventListener 'mouseenter', ((ev) =>
        card = ev.target
        idx = card.dataset.idx
        if card.classList.contains "inactive"
          @guide.children[idx].classList.add 'preview'
      ), false

      card.addEventListener 'mouseleave', ((ev) =>
        card = ev.target
        idx = card.dataset.idx
        if card.classList.contains "inactive"
          @guide.children[idx].classList.remove 'preview'
      ), false

      card.addEventListener 'scroll', @scroll_lock, false

      card.onclick = (ev) =>
        card = ev.target
        if card.classList.contains "inactive"
          @go_to card.dataset.idx

      # TODO touch listeners
      card.addEventListener 'touchstart', @handle_touch_down, false
      card.addEventListener 'touchmove', @handle_touch_up, false

    # set listeners for anchors
    for anchor in document.querySelectorAll "a.local"
      anchor.addEventListener 'click', ((ev) =>
        @parse_href ev.target.href), false

    @logo.addEventListener 'click', ((ev) => @set_active 'root')

  #
  # SETUP
  #

  add_deck: ( deck ) ->
    @decks[deck.name] = deck

  # sets a deck as active and manages entrance/exiting
  set_active: ( name ) ->
    # don't bother activating a nonexistant deck
    if !@decks[name] then return

    delay = 0

    # if a deck is active, tell it to exit
    if @active?
      if name is @active.name
        @go_to 0
        return
      @active.exit()
      delay = 500

    # activate the requested deck
    @active = @decks[name]

    title = @active.div.id
    document.title = @title + if title is 'Root' then '' else " // #{title}"

    # draw it
    window.setTimeout( (() => @build_deck()), delay )

  # draws the active deck into the target hand and builds an index for it
  # sets up handlers for the deck's cards to interact with the board elements
  build_deck: () ->
    @active.enter @targ

    @set_logo()
    @build_guide()
    window.setTimeout( (() => @update_guide()), 0 )

  # resizes the board based on window size
  scale: () ->
    # TODO mobile resolutions
    @resize_guide()

  # scales the idx to match the card target
  resize_guide: () ->
    b_r = document.querySelector( 'body' ).getBoundingClientRect()

    if b_r.width < 600
      @idx.style.height = ""
    else
      t_r = @targ.getBoundingClientRect()
      @idx.style.height = "#{t_r.height}px"

  set_logo: () ->
    e = document.getElementById "E"
    if @active.name == 'root'
      for bar in e.children
        bar.classList.remove 'active'
    else
      for bar in e.children
        bar.classList.add 'active'

  #
  build_guide: () ->
    @resize_guide()

    @guide.innerHTML = ""
    for card, idx in @active.deck
      @guide.innerHTML += "<item data-idx=\"#{idx}\"><span>#{card.title}</span></item>"

    for item, i in document.querySelectorAll 'item > span'
      item.addEventListener 'click', ((ev) =>
        item = ev.target.parentNode
        @go_to item.dataset.idx
      ), false
      # item.addEventListener 'click', ((ev) =>
      #   item = ev.target
      #   @go_to item.dataset.idx
      # ), true

  #
  # CONTROL METHODS
  #

  #
  # # TOUCH EVENTS
  #

  handle_touch_up: (ev) =>
    if (!@touch_x or !@touch_y) then return
    ev.preventDefault()

    # console.log "last touch at (#{@touch_x}, #{@touch_y})"
    #
    # console.log ev

    up_x = ev.touches[0].clientX
    up_y = ev.touches[0].clientY
    # up_x = ev.changedTouches[0].clientX
    # up_y = ev.changedTouches[0].clientY

    dx = @touch_x - up_x
    dy = @touch_y - up_y

    now = new Date().getTime()
    dt = now - @scroll_stamp

    if Math.abs( dy ) < 100 then return
    if dt < @scroll_delay then return

    @scroll_stamp = now

    @touch_x = up_x
    @touch_y = up_y

    # we only care about swiping up or down
    if Math.abs( dy ) > Math.abs( dx )
      if dy > 0
        @active.next_card()
      else
        @active.last_card()

      @update_guide()

  handle_touch_down: (ev) =>
    @touch_x = ev.touches[0].clientX
    @touch_y = ev.touches[0].clientY

  # set the idx elements to match the active deck configuration
  update_guide: () ->
    # the list of index elements
    list = @guide.children
    # the list of active cards
    cards = @active.deck
    # which card is currently active?
    active_idx = @active.active

    # update each element's position
    for item, i in list
      item.classList.remove "preview"
      if i < active_idx
        item.classList.remove "active"
      else if i > active_idx
        item.classList.remove "active"
      else
        item.classList.add "active"

  #
  # # SCROLLING
  #

  # handle scroll events, determining whether to scroll up or down the deck
  parse_scroll: ( ev ) =>
    now = new Date().getTime()
    dt = now - @scroll_stamp

    if dt < @scroll_delay then return

    @scroll_buff += (if ev.deltaY < 0 then -1 else 1)

    if @scroll_thresh >= Math.abs( @scroll_buff ) then return

    # up or down?
    if @scroll_buff > 0
      @active.next_card()
    else
      @active.last_card()

    # update the index to match the current selection
    @update_guide()
    @scroll_lock()

  # reset the scroll buffer and timestamp
  scroll_lock: ( mult=1 ) =>
    # update the scroll timestamp
    @scroll_stamp = new Date().getTime()

    # reset the scroll buffer
    @scroll_buff = 0

  #
  # # LINKS
  #

  # sets the deck to a card index and updates the idx
  go_to: ( card_idx ) ->
    scroll_cb = @active.set_active( parseInt card_idx )
    @update_guide()

  parse_href: ( href ) ->
    ref = href.split( '#' )[1]
    deck_title = ref.split( '_' )[0]

    deck_div = document.getElementById deck_title
    deck_obj = @decks[deck_div.dataset.title]

    if deck_obj?
      if ref.split( '_' ).length is 1
        idx = 0
      else
        c_ref = document.getElementById ref
        idx = c_ref.dataset.idx

      if deck_obj is @active
        @go_to idx
      else
        @set_active deck_div.dataset.title
        window.setTimeout( (() => @go_to idx), 200 )

window.onload = () ->
  # make base elements for the board
  hand = document.querySelector 'hand'
  idx  = document.querySelector 'index'

  # make the root deck
  root_div = document.getElementById 'Root'
  root_deck = new Deck 'root', root_div

  # RayTracing deck
  raytrace_div = document.getElementById 'RayTracer'
  raytrace_deck = new Deck "raytracer", raytrace_div

  # DigitalLiterature deck
  diglit_div = document.getElementById 'DigitalLiterature'
  diglit_deck = new Deck "diglit", diglit_div

  # Ravenmasker deck
  ravenmasker_div = document.getElementById 'Ravenmasker'
  ravenmasker_deck = new Deck "ravenmasker", ravenmasker_div

  # make the board
  board = new Board hand, idx

  # add the root deck
  board.add_deck root_deck
  board.add_deck raytrace_deck
  board.add_deck diglit_deck
  board.add_deck ravenmasker_deck
  # TODO add more decks

  # initialize the Board
  board.init()

  if document.getElementById 'NoJS'
    name = "ekliot"
    mail = "gmail.com"
    document.getElementById( "NoJS" ).innerHTML = " at <a href =\"mailto:#{name}@#{mail}\">#{name}@#{mail}</a>"

  url = location
  console.log url
  href = url.href.split( '#' )[1]
  # set the initial deck
  if href
    board.parse_href url.href
  else
    board.set_active "root"
