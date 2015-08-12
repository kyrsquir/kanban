App =
  init: ->
    console.log "Initializing"
    Vue.use(VueDnd);
    Vue.config.debug = true
    lists = new Vue(
      el: "body"
      data:
        boards: null
        showSettings: false
        showBoards: false
        showModal: false
        # sample data
        board: {
          name: 'Kanban'
          backgroundColor: '519839'
        }
        lists: [
          { id: 1, name: "List 1", position: 1,
          cards: [
              { id: 1, name: 'Card A', position: 1 },
              { id: 2, name: 'Card B', position: 2 },
            ]
          },
          { id: 2, name: "List 2", position: 2,
          cards: [
              { id: 3, name: 'Card C', position: 1 }
            ]
          },
          { id: 3, name: "List 3", position: 4,
          cards: [
              { id: 4, name: 'Card D', position: 1 },
              { id: 5, name: 'Card E', position: 3 },
              { id: 6, name: 'Card F', position: 2 },
            ]
          },
          { id: 4, name: "List 4", position: 6, cards: [] },
          { id: 5, name: "List 5", position: 5, cards: [] },
          { id: 6, name: "List 6", position: 3, cards: [] }
        ]
        colors: ['0079bf', 'd29034', '519839', 'b04632', '89609e',
                 'cd5a91', '4bbf6b', '00aecc', '838c91', '333',
                 '202020', '2ecc71', 'ed7669', '272b33']

      methods:
        toggleSettings: ->
          this.showSettings = !this.showSettings

        toggleBoards: ->
          console.log this.showBoards
          if this.showBoards
            # getBoards
            this.getBoards
          this.showBoards = !this.showBoards

        changeBackground: (color) ->
          this.board.backgroundColor = color

        getBoards: ->
          console.log "eee"
          xhr = new XMLHttpRequest()
          apiURL = "https://projects-api.herokuapp.com/api/boards"
          xhr.open('GET', apiURL)
          xhr.setRequestHeader('Authorization', 'Token token="111"')
          xhr.onload = ->
            this.boards = JSON.parse(xhr.response)
            console.log this.boards
          xhr.send()

        addList: ->
          console.log this.newList
          value = this.newList.replace(/^\s+|\s+$/g, "")
          # TODO
          # set list position to last index
          this.lists.push({ name: value, position: 10, cards: [] })
          this.newList = ''
          # console.log e.target.tagName
        saveList: ->
          value = this.list.name.trim()
          console.log value
        sort: (list, id, tag, data) ->
          console.log(list, data);
          tmp = list[data.index]
          console.log(tmp, data.index);
          list.splice data.index, 1
          list.splice id, 0, tmp

        move: () ->
          console.log('moving');

      components:
        list:
          template: '<article><component is="{{view}}" val="{{list}}" on-done="{{toggle}}"></component>
                      <div class="cards">
                        <card v-repeat="card: list.cards | orderBy \'position\'" class="cards"></card>
                        <p v-on="click: showCreate" class="add-card" v-if="!enter">
                          Add a card...
                        </p>
                      </div>
                    </article>'
          data: ->
            view: 'listName'
          methods:
            toggle: (view, val) ->
              this.view = view
            showCreate: ->
              position = 0
              if(this.list.cards.length > 0)
                lastItem = this.list.cards[this.list.cards.length - 1]
                position = lastItem.position
              this.list.cards.push({ name: "New", position: position++})

          # child components for list
          components:
            listName:
              props: ['val', 'on-done']
              template: "<p v-on='click: edit' class='title'>{{ val.name }}</p>"
              methods:
                edit: ->
                  this.onDone('listForm')
            listForm:
              props: ['val', 'on-done']
              template: "
                          <input v-model='val.name' class='form-control mb1' v-el='listname'>
                          <button v-on='click: save' class='btn btn-success mb2'>Save</button>
                          <button v-on='click: close' class='btn btn-default mb2'>Close</button>"
              created: ->
                console.log('out');
                Vue.nextTick( =>
                  this.$$.listname.focus()
                )
              methods:
                close: ->
                  original_name = this.val.name
                  console.log this.val.name
                  this.onDone('listName', original_name)
                  console.log original_name
                save: ->
                  console.log 'list saved'
                  this.onDone('listName', this.val)
                  # sync to server

            card:
              template: '<component is="{{view}}" val="{{card}}" on-done="{{toggle}}" keep-alive></component>'
              data: ->
                view: 'cardName'
              methods:
                toggle: (view, val) ->
                  this.view = view

              # child components of card
              components:
                cardName:
                  filters:
                    marked: marked
                  props: ['val', 'on-done']
                  template: "<div v-html='val.name | marked' v-on='click: edit' class='card'></div>"
                  methods:
                    edit: ->
                      this.onDone('cardForm')

                cardForm:
                  props: ['val', 'on-done']
                  template: "<textarea v-model='val.name' rows='3' class='form-control mb1 card-input' autofocus></textarea>
                              <button v-on='click: save' class='btn btn-success mb2'>Save</button>
                              <button v-on='click: close' class='btn btn-default mb2'>Close</button>"
                  data: ->
                    val: []
                  methods:
                    close: ->
                      this.onDone('cardName', this.val)
                    save: ->
                      console.log 'card saved'
                      this.onDone('cardName', this.val)
                      # sync to server
    )

# Inititalize main component
new App.init
