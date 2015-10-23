Array::move = (dragIndex, dropIndex) ->
  dropIndex-- if dragIndex < dropIndex
  @splice dropIndex, 0, @splice(dragIndex, 1)[0]

Array::getElementIndex = (key, value) ->
  for v, i in @
    if v[key] == value
      return i
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
          console.log 'updateBoard', @lists
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

        dropList: (drag) ->
          lists = @.lists
          dragPosition = lists.getElementIndex 'slug', drag.list.slug
          lists.push lists.splice(dragPosition, 1)[0]
          @updateBoard()

      components:
        list:
          template: '<article class="list-dropzone" v-dropzone="y: moveList($dropdata, list)"></article>
                     <article>\
                       <component is="{{view}}" val="{{list}}" list="{{list}}" on-done="{{toggle}}"></component>\
                       <div class="cards">\
                           <card v-repeat="card: list.cards" track-by="$index"></card>\
                           <div class="card-dropzone" v-dropzone="x: dropCard($dropdata)"></div>\
                           <p v-on="click: showCreate" class="add-link" v-if="!enter">\
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
            moveList: (drag, dropZone) ->
              lists = @$parent.lists
              dragIndex = lists.getElementIndex 'slug', drag.list.slug
              dropIndex = lists.getElementIndex 'slug', dropZone.slug
              lists.move dragIndex, dropIndex
              @$parent.updateBoard()
            dropCard: (drag) ->
              dropCards = @list.cards
              lists = @$parent.lists
              dragList = lists[lists.getElementIndex 'slug', drag.list.slug]
              dragCards = dragList.cards
              dragPosition = dragCards.getElementIndex 'slug', drag.card.slug
              dropCards.push dragCards.splice(dragPosition, 1)[0]
              @$parent.updateBoard()
          # child components for list
          components:
            listName:
              props: ['val', 'on-done']
              template: '<p class="title"\
                            v-on="click: edit"\
                            v-draggable="y: {list: val}">\
                            {{ val.name }}\
                         </p>'
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
                  template: '<div class="card-dropzone" v-dropzone="x: moveCard($dropdata, val, list)"></div>
                             <div class="card" v-draggable="x: {card: val, list: list, dragged: \'dragged\'}">\
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
                    moveCard: (drag, dropZone, dropList) ->
                      lists = @$parent.$parent.$parent.lists
                      dragListId = drag.list.slug
                      dropListId = dropList.slug
                      dragList = lists[lists.getElementIndex 'slug', dragListId]
                      dragListCards = dragList.cards
                      dropListCards = dropList.cards
                      dragPosition = dragListCards.getElementIndex 'slug', drag.card.slug
                      dropPosition = dropListCards.getElementIndex 'slug', dropZone.slug
                      if dragListId == dropListId
                        dragListCards.move dragPosition, dropPosition
                      else
                        dropListCards.splice dropPosition, 0, dragListCards.splice(dragPosition, 1)[0]
                      @$parent.$parent.$parent.updateBoard()
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
                      @$parent.$parent.$parent.updateBoard()

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
