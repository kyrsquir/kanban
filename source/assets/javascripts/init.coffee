App =
  init: ->
    console.log "Initializing"
    Vue.use(VueDnd);
    Vue.config.debug = true
    lists = new Vue(
      el: "body"
      data:
        board: {
          name: 'Kanban'
          backgroundColor: '519839'
        }
        showSettings: false
        showModal: false
        # sample data
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

        changeBackground: (color) ->
          this.board.backgroundColor = color

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
                        <p v-on="click: showCreate()" class="add-card" v-if="!enter">
                        Add a card...
                        </p>
                        <div v-if="enter">
                          <textarea v-model="new_card" v-el="cardInput" rows="3" class="form-control mb1 card-input"></textarea>
                          <button v-on="click: create()" class="btn btn-success mb2">Save</button>
                          <button v-on="click: close()" class="btn btn-default mb2">Close</button>
                        </div>
                      </div>
                    </article>'
          data: ->
            view: 'listName'
            enter: false
            new_card: ''
          created: ->
            this.$on('closeCreate', =>
              this.enter = false
            )
          methods:
            toggle: (view, val) ->
              this.view = view
            showCreate: ->
              this.enter = true
              # this will toggle the input
              Vue.nextTick( =>
                this.$$.cardInput.focus()
              )
            close: ->
              this.enter = false
            create: () ->
              console.log('ok')
              value = this.new_card.replace(/^\s+|\s+$/g, "")
              if value.trim()
                # TODO
                # set card position to last index
                this.list.cards.push({ name: value, position: 10, cards: [] })
                this.new_card = ''
                this.enter = false

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
                  this.onDone('listName', this.val)
                  # sync to server

            card:
              template: '<component is="{{view}}" val="{{card}}" on-done="{{toggle}}" keep-alive></component>'
              data: ->
                view: 'cardName'

              created: ->
                this.$on('closeAll', =>
                  this.toggle('cardName')
                )
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
                      this.onDone('cardName', this.val)
                      # sync to server
    )

# Inititalize main component
new App.init
