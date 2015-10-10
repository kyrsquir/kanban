getElementIndex = (arrOfObj, key, value) ->
  i = undefined
  length = arrOfObj.length
  i = 0
  while i < length
    if arrOfObj[i][key] == value
      return i
    i++
  -1

App =
  init: ->
    console.log "Initializing"
    for i in [VueResource, VueDnd]
      Vue.use(i)
    Vue.config.debug = true
    Vue.http.headers.common['Content-type'] = 'application/json'
    Vue.http.headers.common['Authorization'] = 'Token token="111"'
    apiURL = "https://api-kanban.herokuapp.com/api"
    # apiURL = "http://localhost:3025/api"
    boardsURL = apiURL + '/boards'

    new Vue(
      el: "body"

      ready: ->
        @getBoards()

      data:
        boards: []
        currentBoard: {}
        lists: []
        showSettings: false
        showBoards: false
        showModal: false
        colors: ['0079bf', 'd29034', '519839', 'b04632', '89609e',
                 'cd5a91', '4bbf6b', '00aecc', '838c91', '333',
                 '202020', '2ecc71', 'ed7669', '272b33']

      methods:
        toggleSettings: ->
          this.showSettings = !this.showSettings

        toggleBoards: ->
          this.showBoards = !this.showBoards

        changeBackground: (color) ->
          this.currentBoard.background_color = color

        saveBoard: ->
          @updateBoard()
          @toggleSettings()

        updateBoard: ->
          boardURL = apiURL + '/boards/' + @currentBoard.id
          @$http.put(boardURL,
            {
              name: @currentBoard.name
              background_color: @currentBoard.background_color
              lists: @lists
            },
            (data, status, request) ->
          ).error (data, status, request) ->
            console.log status + ' - ' + request

        setCurrentBoard: (board) ->
          @currentBoard = board
          @lists = board.lists

        getBoards: ->
          @$http.get(boardsURL, (data, status, request) ->
            @$set 'boards', data
            @$set 'currentBoard', data[1]
            @$set 'lists', data[1].lists
          ).error (data, status, request) ->
            console.log status + ' - ' + request

        addList: ->
          console.log @newList
          value = @newList.replace(/^\s+|\s+$/g, "")

          position = 0
          if @lists.length > 0
            position = @lists.length + 1
          @lists.push({
            name: value
            position: position
          })
          @newList = ''
          @updateBoard()

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
          template: '<article>\
                       <component is="{{view}}" val="{{list}}" list="{{list}}" on-done="{{toggle}}"></component>\
                       <div class="cards">\
                           <card v-repeat="card: list.cards | orderBy \'position\'"></card>\
                           <p v-on="click: showCreate" class="add-link" v-if="!enter" v-dropzone="x: add($dropdata)">\
                               Add a card...\
                           </p>\
                       </div>\
                     </article>'
          data: ->
            view: 'listName'
          methods:
            toggle: (view, val) ->
              this.view = view
            showCreate: ->
              position = @list.cards.length + 1
              this.list.cards.push({
                name: "New Card"
                position: position
              })
              ###position = 0
              if this.list.cards.length > 0
                lastItem = this.list.cards[this.list.cards.length - 1]
                position = lastItem.position
              this.list.cards.push({
                name: "New Card"
                position: position++
              })###
            add: (drag) ->
              dropCards = @list.cards
              lists = @$parent.lists
              dragList = lists[getElementIndex(lists, 'name', drag.list.name)]
              dragCards = dragList.cards
              dragPosition = drag.card.position
              dragIndex = getElementIndex(dragCards, 'position', dragPosition)
              dropCards.push dragCards.splice(dragIndex, 1)[0]
              dropCards[dropCards.length - 1].position = dropCards.length
              while i < length
                if dragCards[i].position > dragPosition
                  dragCards[i].position--
                i++
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
              template: "<input v-model='val.name' class='form-control mb1' v-el='listname'>
                         <button v-on='click: save' class='btn btn-success mb2'>Save</button>
                         <button v-on='click: close' class='btn btn-default mb2'>Close</button>"
              created: ->
                console.log('out');
                Vue.nextTick(=>
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
                  # @updateBoard()

            card:
              inherit: true
              template: '<component is="{{view}}" val="{{card}}" list="{{list}}" on-done="{{toggle}}" keep-alive></component>'
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
                  props: ['val', 'on-done', 'list']
                  template: '<div class="card"\
                                  v-draggable="x: {card: val, list: list}"\
                                  v-dropzone="x: move($dropdata, val, list)">\
                               <span class="glyphicon glyphicon-pencil pull-right"\
                                     v-on="click: edit">\
                               </span>\
                               <component v-html="val.name | marked"\
                                          v-on="click: show">\
                                 {{val.name}}\
                               </component>\
                             </div>'
                  methods:
                    edit: ->
                      this.onDone('cardForm')
                    show: ->
                      this.onDone('cardModal')
                    move: (drag, dropCard, dropList) ->
                      lists = @$parent.$parent.$parent.lists
                      dragList = lists[getElementIndex(lists, 'name', drag.list.name)]
                      dragPosition = drag.card.position
                      dropPosition = dropCard.position
                      dragCards = dragList.cards
                      dropCards = dropList.cards
                      dragIndex = getElementIndex(dragCards, 'position', dragPosition)
                      dropIndex = getElementIndex(dropCards, 'position', dropPosition)
                      dragElement = dragCards[dragIndex]
                      dropElement = dropCards[dropIndex]
                      targetPosition = dropPosition

                      ###var drag1 = dragCards.map(function (obj) {
                       return obj.name + ' ' + obj.position
                       }),
                       drop1 = dropCards.map(function (obj) {
                       return obj.name + ' ' + obj.position
                       });
                      ###
                      if drag.list.name == dropList.name
                        dragElement.position = dropPosition
                        dropElement.position = dragPosition
                      else
                        plucked = dragCards.splice(dragIndex, 1)[0]
                        plucked.position = targetPosition
                        dropCards.push plucked
                        i = 0
                        length = dragCards.length
                        while i < length
                          if dragCards[i].position > dragPosition
                            dragCards[i].position--
                          i++
                        i = 0
                        length = dropCards.length
                        while i < length - 1
                          if dropCards[i].position >= targetPosition
                            dropCards[i].position++
                          i++
                        ###var drag2 = dragCards.map(function (obj) {
                         return obj.name + ' ' + obj.position
                         }),
                         drop2 = dropCards.map(function (obj) {
                         return obj.name + ' ' + obj.position
                         });
                         console.log('dragcards', drag1, '->', drag2);
                         console.log('dropcards', drop1, '->', drop2);
                        ###
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
                      # TODO Bug fix
                      # @updateBoard()

                cardModal:
                  props: ['val', 'on-done']
                  template: '
                      <modal show="{{true}}">
                        <h4 class="modal-title">
                          {{val.name}}
                        </h4>
                        <div class="modal-body">
                          <p>Comments: {{val.comments}}</p>
                          <p>Tags: {{val.tags}}</p>
                          <p>Members: {{val.members}}</p>
                          <p>Delete</p>
                          <p>Archive</p>
                        </div>
                      </modal>'
    )

# Inititalize main component
new App.init
