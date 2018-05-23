// Generated by CoffeeScript 2.1.0
(function() {
  var Board, Card, Deck;

  Card = class Card {
    constructor(deck, id, title) {
      this.deck = deck;
      this.id = id;
      this.div = document.getElementById(`${id}`);
      this.title = title;
      this.active = false;
    }

    toggle_active() {
      return this.active = !this.active;
    }

    get_div() {
      return document.getElementById(`${this.id}`);
    }

    
    // ANIMATION

    swipe(dir = 'up') {
      var div, rem, rot, top;
      rem = parseFloat(getComputedStyle(document.documentElement).fontSize);
      div = this.get_div();
      top = dir === 'up' ? -120 : 120;
      rot = dir === 'up' ? 10 : -10;
      div.classList.add("swiped");
      div.style.top = `${top}%`;
      div.style.left = `-${rem}`;
      div.style.transform = `rotate(${rot}deg)`;
      div.style["-moz-transform"] = `rotate(${rot}deg)`;
      div.style["-webkit-transform"] = `rotate(${rot}deg)`;
      return window.setTimeout((() => {
        return this.set_z(0);
      }), 500);
    }

    set_z(z) {
      var div;
      div = this.get_div();
      div.style["z-index"] = "0";
      div.style.transform = "rotate(0deg)";
      div.style["-moz-transform"] = "rotate(0deg)";
      return div.style["-webkit-transform"] = "rotate(0deg)";
    }

  };

  Deck = class Deck {
    constructor(name, deck) {
      this.name = name;
      // Array of Cards
      this.deck = [];
      // HTMLElement <deck>
      this.div = deck;
      this.size = 0;
      this.active = 0;
      this.build_deck();
    }

    // add <card> elements of @div as Cards into the Card Array
    build_deck() {
      var card, idx, j, len, ref1, results;
      idx = 0;
      ref1 = this.div.children;
      results = [];
      for (j = 0, len = ref1.length; j < len; j++) {
        card = ref1[j];
        card.dataset.idx = idx;
        this.add_card(new Card(this.name, card.id, card.dataset.title));
        results.push(idx++);
      }
      return results;
    }

    add_card(card) {
      this.deck.push(card);
      return this.size++;
    }

    get_active() {
      return this.deck[this.active];
    }

    set_active(idx, dir = 'def') {
      var i, j, k, l, last, ref1, ref2, ref3, ref4, ref5;
      if (idx === this.active) {
        return;
      }
      last = this.active;
      this.active = idx;
      // dumb ifelse monstrosity...

      // if we are scrolling backwards...
      if (last > this.active) {
        // console.log 1
        for (i = j = ref1 = last, ref2 = this.size; ref1 <= ref2 ? j < ref2 : j > ref2; i = ref1 <= ref2 ? ++j : --j) {
          this.deck[i].swipe(dir === 'def' ? 'up' : dir);
        }
        // and, if the next active card is not the first card...
        if (this.active !== 0) {
          // console.log 2
          for (i = k = 0, ref3 = this.active; 0 <= ref3 ? k < ref3 : k > ref3; i = 0 <= ref3 ? ++k : --k) {
            this.deck[i].swipe(dir === 'def' ? 'up' : dir);
          }
        }
      } else {
        // console.log 3
        // otherwise
        for (i = l = ref4 = last, ref5 = this.active; ref4 <= ref5 ? l < ref5 : l > ref5; i = ref4 <= ref5 ? ++l : --l) {
          this.deck[i].swipe(dir === 'def' ? 'up' : dir);
        }
      }
      return window.setTimeout((() => {
        return this.update_layout();
      }), 500);
    }

    next_card() {
      return this.set_active((this.active === this.size - 1 ? 0 : this.active + 1), 'up');
    }

    last_card() {
      return this.set_active((this.active === 0 ? this.size - 1 : this.active - 1), 'down');
    }

    enter(target) {
      var i, j, ref1;
      for (i = j = ref1 = this.size - 1; j >= 0; i = j += -1) {
        target.appendChild(this.deck[i].get_div());
      }
      // for some reason, the animations don't work unless we set it up in a timeout
      return window.setTimeout((() => {
        return this.update_layout();
      }), 0);
    }

    exit() {
      var card, j, len, ref1;
      ref1 = this.deck;
      for (j = 0, len = ref1.length; j < len; j++) {
        card = ref1[j];
        card.get_div().style = "";
        card.get_div().classList.remove("inactive");
      }
      return window.setTimeout((() => {
        var k, len1, ref2, results;
        ref2 = this.deck;
        results = [];
        for (k = 0, len1 = ref2.length; k < len1; k++) {
          card = ref2[k];
          results.push(this.div.appendChild(card.get_div()));
        }
        return results;
      }), 500);
    }

    // return
    update_layout() {
      var card, draw_cnt, i, j, k, ref1, ref2, ref3, rem, results;
      rem = parseFloat(getComputedStyle(document.documentElement).fontSize);
      draw_cnt = 1;
      // draw the cards from back to front
      for (i = j = ref1 = this.active - 1; j >= 0; i = j += -1) {
        card = this.deck[i].get_div();
        card.style["z-index"] = `${draw_cnt}`;
        card.style.left = `${(this.size - draw_cnt) * rem}px`;
        card.style.top = `-${(this.size - draw_cnt) * rem}px`;
        card.classList.add("inactive");
        draw_cnt += 1;
      }
      results = [];
      for (i = k = ref2 = this.size - 1, ref3 = this.active; k >= ref3; i = k += -1) {
        card = this.deck[i].get_div();
        card.style["z-index"] = `${draw_cnt}`;
        card.style.left = `${(this.size - draw_cnt) * rem}px`;
        card.style.top = `-${(this.size - draw_cnt) * rem}px`;
        if (i !== this.active) {
          card.classList.add("inactive");
        } else {
          card.classList.remove("inactive");
        }
        results.push(draw_cnt += 1);
      }
      return results;
    }

  };

  Board = class Board {
    constructor(targ, idx) {
      // item.addEventListener 'click', ((ev) =>
      //   item = ev.target
      //   @go_to item.dataset.idx
      // ), true

      // CONTROL METHODS

      // # TOUCH EVENTS

      this.handle_touch_up = this.handle_touch_up.bind(this);
      this.handle_touch_down = this.handle_touch_down.bind(this);
      
      // # SCROLLING

      // handle scroll events, determining whether to scroll up or down the deck
      this.parse_scroll = this.parse_scroll.bind(this);
      // reset the scroll buffer and timestamp
      this.scroll_lock = this.scroll_lock.bind(this);
      // HTMLElement <hand>
      this.targ = targ;
      // HTMLElement <index>
      this.idx = idx;
      // HTMLElement <ul>
      this.guide = idx.querySelector('guide');
      // HTMLElement <a>
      this.logo = idx.querySelector('#E');
      // Deck.name -> Deck
      this.decks = {};
      // Deck
      this.active = null;
      this.title = "Elijah Kliot";
      // scroll control
      this.scroll_stamp = new Date().getTime();
      this.scroll_buff = 0;
      this.scroll_delay = 500;
      this.scroll_thresh = 5;
    }

    init() {
      var anchor, card, j, k, len, len1, ref1, ref2;
      this.scale();
      // set resize listener
      window.addEventListener('resize', (() => {
        if (this.active != null) {
          return this.scale();
        }
      }), true);
      // set scroll listener
      window.addEventListener('wheel', this.parse_scroll, false);
      ref1 = document.querySelectorAll('card');
      // set listeners for each card
      for (j = 0, len = ref1.length; j < len; j++) {
        card = ref1[j];
        card.addEventListener('mouseenter', ((ev) => {
          var idx;
          card = ev.target;
          idx = card.dataset.idx;
          if (card.classList.contains("inactive")) {
            return this.guide.children[idx].classList.add('preview');
          }
        }), false);
        card.addEventListener('mouseleave', ((ev) => {
          var idx;
          card = ev.target;
          idx = card.dataset.idx;
          if (card.classList.contains("inactive")) {
            return this.guide.children[idx].classList.remove('preview');
          }
        }), false);
        card.addEventListener('scroll', this.scroll_lock, false);
        card.onclick = (ev) => {
          card = ev.target;
          if (card.classList.contains("inactive")) {
            return this.go_to(card.dataset.idx);
          }
        };
        // TODO touch listeners
        card.addEventListener('touchstart', this.handle_touch_down, false);
        card.addEventListener('touchmove', this.handle_touch_up, false);
      }
      ref2 = document.querySelectorAll("a.local");
      // set listeners for anchors
      for (k = 0, len1 = ref2.length; k < len1; k++) {
        anchor = ref2[k];
        anchor.addEventListener('click', ((ev) => {
          return this.parse_href(ev.target.href);
        }), false);
      }
      return this.logo.addEventListener('click', ((ev) => {
        return this.set_active('root');
      }));
    }

    
    // SETUP

    add_deck(deck) {
      return this.decks[deck.name] = deck;
    }

    // sets a deck as active and manages entrance/exiting
    set_active(name) {
      var delay, title;
      if (!this.decks[name]) {
        return;
      }
      delay = 0;
      // if a deck is active, tell it to exit
      if (this.active != null) {
        if (name === this.active.name) {
          this.go_to(0);
          return;
        }
        this.active.exit();
        delay = 500;
      }
      // activate the requested deck
      this.active = this.decks[name];
      title = this.active.div.id;
      document.title = this.title + (title === 'Root' ? '' : ` // ${title}`);
      // draw it
      return window.setTimeout((() => {
        return this.build_deck();
      }), delay);
    }

    // draws the active deck into the target hand and builds an index for it
    // sets up handlers for the deck's cards to interact with the board elements
    build_deck() {
      this.active.enter(this.targ);
      this.set_logo();
      this.build_guide();
      return window.setTimeout((() => {
        return this.update_guide();
      }), 0);
    }

    // resizes the board based on window size
    scale() {
      // TODO mobile resolutions
      return this.resize_guide();
    }

    // scales the idx to match the card target
    resize_guide() {
      var b_r, t_r;
      b_r = document.querySelector('body').getBoundingClientRect();
      if (b_r.width < 600) {
        return this.idx.style.height = "";
      } else {
        t_r = this.targ.getBoundingClientRect();
        return this.idx.style.height = `${t_r.height}px`;
      }
    }

    set_logo() {
      var bar, e, j, k, len, len1, ref1, ref2, results, results1;
      e = document.getElementById("E");
      if (this.active.name === 'root') {
        ref1 = e.children;
        results = [];
        for (j = 0, len = ref1.length; j < len; j++) {
          bar = ref1[j];
          results.push(bar.classList.remove('active'));
        }
        return results;
      } else {
        ref2 = e.children;
        results1 = [];
        for (k = 0, len1 = ref2.length; k < len1; k++) {
          bar = ref2[k];
          results1.push(bar.classList.add('active'));
        }
        return results1;
      }
    }

    
    build_guide() {
      var card, i, idx, item, j, k, len, len1, ref1, ref2, results;
      this.resize_guide();
      this.guide.innerHTML = "";
      ref1 = this.active.deck;
      for (idx = j = 0, len = ref1.length; j < len; idx = ++j) {
        card = ref1[idx];
        this.guide.innerHTML += `<item data-idx="${idx}"><span>${card.title}</span></item>`;
      }
      ref2 = document.querySelectorAll('item > span');
      results = [];
      for (i = k = 0, len1 = ref2.length; k < len1; i = ++k) {
        item = ref2[i];
        results.push(item.addEventListener('click', ((ev) => {
          item = ev.target.parentNode;
          return this.go_to(item.dataset.idx);
        }), false));
      }
      return results;
    }

    handle_touch_up(ev) {
      var dt, dx, dy, now, up_x, up_y;
      if (!this.touch_x || !this.touch_y) {
        return;
      }
      ev.preventDefault();
      // console.log "last touch at (#{@touch_x}, #{@touch_y})"

      // console.log ev
      up_x = ev.touches[0].clientX;
      up_y = ev.touches[0].clientY;
      // up_x = ev.changedTouches[0].clientX
      // up_y = ev.changedTouches[0].clientY
      dx = this.touch_x - up_x;
      dy = this.touch_y - up_y;
      now = new Date().getTime();
      dt = now - this.scroll_stamp;
      if (Math.abs(dy) < 100) {
        return;
      }
      if (dt < this.scroll_delay) {
        return;
      }
      this.scroll_stamp = now;
      this.touch_x = up_x;
      this.touch_y = up_y;
      // we only care about swiping up or down
      if (Math.abs(dy) > Math.abs(dx)) {
        if (dy > 0) {
          this.active.next_card();
        } else {
          this.active.last_card();
        }
        return this.update_guide();
      }
    }

    handle_touch_down(ev) {
      this.touch_x = ev.touches[0].clientX;
      return this.touch_y = ev.touches[0].clientY;
    }

    // set the idx elements to match the active deck configuration
    update_guide() {
      var active_idx, cards, i, item, j, len, list, results;
      // the list of index elements
      list = this.guide.children;
      // the list of active cards
      cards = this.active.deck;
      // which card is currently active?
      active_idx = this.active.active;
      results = [];
      // update each element's position
      for (i = j = 0, len = list.length; j < len; i = ++j) {
        item = list[i];
        item.classList.remove("preview");
        if (i < active_idx) {
          results.push(item.classList.remove("active"));
        } else if (i > active_idx) {
          results.push(item.classList.remove("active"));
        } else {
          results.push(item.classList.add("active"));
        }
      }
      return results;
    }

    parse_scroll(ev) {
      var dt, now;
      now = new Date().getTime();
      dt = now - this.scroll_stamp;
      if (dt < this.scroll_delay) {
        return;
      }
      this.scroll_buff += (ev.deltaY < 0 ? -1 : 1);
      if (this.scroll_thresh >= Math.abs(this.scroll_buff)) {
        return;
      }
      // up or down?
      if (this.scroll_buff > 0) {
        this.active.next_card();
      } else {
        this.active.last_card();
      }
      // update the index to match the current selection
      this.update_guide();
      return this.scroll_lock();
    }

    scroll_lock(mult = 1) {
      // update the scroll timestamp
      this.scroll_stamp = new Date().getTime();
      // reset the scroll buffer
      return this.scroll_buff = 0;
    }

    
    // # LINKS

    // sets the deck to a card index and updates the idx
    go_to(card_idx) {
      var scroll_cb;
      scroll_cb = this.active.set_active(parseInt(card_idx));
      return this.update_guide();
    }

    parse_href(href) {
      var c_ref, deck_div, deck_obj, deck_title, idx, ref;
      ref = href.split('#')[1];
      deck_title = ref.split('_')[0];
      deck_div = document.getElementById(deck_title);
      deck_obj = this.decks[deck_div.dataset.title];
      if (deck_obj != null) {
        if (ref.split('_').length === 1) {
          idx = 0;
        } else {
          c_ref = document.getElementById(ref);
          idx = c_ref.dataset.idx;
        }
        if (deck_obj === this.active) {
          return this.go_to(idx);
        } else {
          this.set_active(deck_div.dataset.title);
          return window.setTimeout((() => {
            return this.go_to(idx);
          }), 200);
        }
      }
    }

  };

  window.onload = function() {
    var board, diglit_deck, diglit_div, hand, href, idx, mail, name, ravenmasker_deck, ravenmasker_div, raytrace_deck, raytrace_div, root_deck, root_div, url;
    // make base elements for the board
    hand = document.querySelector('hand');
    idx = document.querySelector('index');
    // make the root deck
    root_div = document.getElementById('Root');
    root_deck = new Deck('root', root_div);
    // RayTracing deck
    raytrace_div = document.getElementById('RayTracer');
    raytrace_deck = new Deck("raytracer", raytrace_div);
    // DigitalLiterature deck
    diglit_div = document.getElementById('DigitalLiterature');
    diglit_deck = new Deck("diglit", diglit_div);
    // Ravenmasker deck
    ravenmasker_div = document.getElementById('Ravenmasker');
    ravenmasker_deck = new Deck("ravenmasker", ravenmasker_div);
    // make the board
    board = new Board(hand, idx);
    // add the root deck
    board.add_deck(root_deck);
    board.add_deck(raytrace_deck);
    board.add_deck(diglit_deck);
    board.add_deck(ravenmasker_deck);
    // TODO add more decks

    // initialize the Board
    board.init();
    if (document.getElementById('NoJS')) {
      name = "ekliot";
      mail = "gmail.com";
      document.getElementById("NoJS").innerHTML = ` at <a href ="mailto:${name}@${mail}">${name}@${mail}</a>`;
    }
    url = location;
    console.log(url);
    href = url.href.split('#')[1];
    // set the initial deck
    if (href) {
      return board.parse_href(url.href);
    } else {
      return board.set_active("root");
    }
  };

}).call(this);
