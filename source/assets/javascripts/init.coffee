App =
  init: ->
    console.log "Initializing"
    Vue.use(VueDnd);
    lists = new Vue(
      el: "body"
      data:
        board: {
          name: 'Kanban'
          backgroundColor: '519839'
        }
        newList: ''
        showSettings: false
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
        toggleList: ->
          console.log "clicked"
          this.showListForm = !this.showListForm
        toggle: (list) ->
          list.name = list.id + " " + list.name
          console.log list.name
        toggleListForm: ->
          # console.log this.el
          listForm == 'true'
          console.log listForm
          # this.$set.listForm = !this.$set.listForm
        toggleSettings: ->
          this.showSettings = !this.showSettings
          false
        changeBackground: (color) ->
          this.board.backgroundColor = color

        addList: ->
          console.log this.newList
          value = this.newList.replace(/^\s+|\s+$/g, "")
          this.lists.push({ name: value, cards: [] })
          this.newList = ''
          # console.log e.target.tagName
        saveList: ->
          value = this.list.name.trim()
          console.log value

        addCard: (list) ->
          # value = this.$set.newCard.replace(/^\s+|\s+$/g, "")
          value = "test"
          list.cards.push({ name: value })
        sort: (list, id, tag, data) ->
          console.log(list, data);
          tmp = list[data.index]
          console.log(tmp, data.index);
          list.splice data.index, 1
          list.splice id, 0, tmp

        move: () ->
          console.log('moving');

      components:
        # mic: mic_component
        list:
          props: ['val']
          template: '<component is="{{view}}" val="{{val}}" on-done="{{toggle}}" keep-alive></component>'
          data: ->
            view: 'listName'
          methods:
            toggle: (view, val) ->
              this.view = view
        listName:
          props: ['val', 'on-done']
          template: "<p v-on='click: edit' class='title'>{{ val.name }}</p>"
          methods:
            edit: ->
              this.onDone('listForm')
        listForm:
          props: ['val', 'on-done']
          template: "<input v-model='val.name' class='form-control mb1' autofocus>
                      <button v-on='click: save' class='btn btn-success mb2'>Save</button>
                      <button v-on='click: close' class='btn btn-default mb2'>Close</button>"
          data: ->
            val: []
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
          props: ['val']
          template: '<component is="{{view}}" val="{{val}}" on-done="{{toggle}}" keep-alive></component>'
          data: ->
            view: 'cardName'
          methods:
            toggle: (view, val) ->
              # TODO
              # fin open card(s) and close (form)
              console.log lists
              for list in lists
                console.log list.name
              this.view = view
        cardName:
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

      filters:
        marked: marked
    )

# Inititalize main component
new App.init
