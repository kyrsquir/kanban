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
    console.log 'Initializing started'
    for i in [VueResource, VueRouter, VueDnd]
      Vue.use i
    Vue.config.debug = true
    Vue.http.headers.common['Content-type'] = 'application/json'
    Vue.http.headers.common['Authorization'] = 'Token token="111"'

    new Vue
      el: 'body'

      ready: ->
        @getBoards()

      data:
#        apiURL: 'http://localhost:3025/api'
        apiURL: 'https://api-kanban.herokuapp.com/api'
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
          @showSettings = !@showSettings

        toggleBoards: ->
          @showBoards = !@showBoards

        changeBackground: (color) ->
          @currentBoard.background_color = color

        saveBoard: ->
          @updateBoard()
          @toggleSettings()

        updateBoard: ->
          console.log 'updateBoard', @lists
          @$http.put(@apiURL + '/boards/' + @currentBoard.id,
              name: @currentBoard.name
              background_color: @currentBoard.background_color
              lists: @lists
            (data, status, request) ->
              console.log status + ' - ' + request
          ).error (data, status, request) ->
            console.log status + ' - ' + request

        setCurrentBoard: (board) ->
          @currentBoard = board
          @lists = board.lists
          @showBoards = false

        getBoards: ->
          @$http.get @apiURL + '/boards', (data) ->
            @$set 'boards', data
            @$set 'currentBoard', data[0]
            @$set 'lists', data[0].lists
            # remove empty card names
#            for list in data[0].lists
#              for card in list.cards
#                card.name = 'New card' if card.name.length < 2
          .error (data, status, request) ->
            console.log status + ' - ' + request

        addList: ->
          value = @newList.replace /^\s+|\s+$/g, ""
          @lists.push
            name: value
            active: false
            cards: []
          @newList = ''
          @updateBoard()

        saveList: ->
          value = @list.name.trim()
          @updateBoard()

        sort: (list, id, tag, data) ->
          tmp = list[data.index]
          list.splice data.index, 1
          list.splice id, 0, tmp

        dropList: (drag) ->
          lists = @.lists
          dragPosition = lists.getElementIndex 'slug', drag.list.slug
          lists.push lists.splice(dragPosition, 1)[0]
          @updateBoard()

      components:
        list:
          template: '<pre>{{ list | json }}</pre>
                     <article class="list-dropzone" v-dropzone="y: moveList($dropdata, list)"></article>
                     <article>
                       <component :is="view" list="{{list}}" toggle-list="{{toggle}}"></component>
                       <div class="cards">
                         <card v-repeat="card: list.cards" track-by="$index"></card>
                         <div class="card-dropzone" v-dropzone="x: dropCard($dropdata)"></div>
                         <p v-on="click: createNewCard" class="add-link" v-if="!isBeingEdited">
                           Add new card...
                         </p>
                       </div>
                     </article>'
          data: ->
            isBeingEdited: false
            view: 'listName'
          methods:
            toggle: (view) ->
              @view = view
            createNewCard: ->
              @list.cards.push
                name: ''
              children = @$children
              Vue.nextTick =>
                children[children.length - 1].toggle 'cardForm'
                @isBeingEdited = true
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
              props: ['list', 'toggle-list']
              template: '<p class="title" v-on="click: edit" v-draggable="y: {list: list}">{{ list.name }}</p>'
              methods:
                edit: ->
                  @list.oldName = @list.name
                  @toggleList 'listForm'
            listForm:
              props: ['list', 'toggle-list']
              template: '<input v-model="list.name" class="form-control mb1" v-el="listNameInput" @keypress.enter.prevent="save" @keyup.esc="close" autofocus>
                         <button v-on="click: save" class="btn btn-success mb2">Save</button>
                         <button v-on="click: close" class="btn btn-default mb2">Close</button>'
              created: ->
                Vue.nextTick =>
                  @$$.listNameInput.focus()
              methods:
                close: ->
                  @list.name = @list.oldName
                  @toggleList 'listName'
                save: ->
                  if !!@list.name
                    @$parent.$parent.updateBoard()
                    @toggleList 'listName'
            card:
              inherit: true
              template: '<component :is="view" card="{{card}}" list="{{list}}" toggle-card="{{toggle}}" keep-alive></component>'
              data: ->
                view: 'cardName'
              methods:
                toggle: (view) ->
                  if view == 'cardForm'
                    for component in @$parent.$parent.$children
                      if component.isBeingEdited
                        for childComponent in component.$children
                          if childComponent.view == 'cardForm'
                            childComponent.$children[1].close()
                  @view = view
              # child components of card
              components:
                cardName:
                  filters:
                    marked: marked
                  props: ['card', 'toggle-card', 'list']
                  data: ->
                    showModal: false
                  template: '<div class="card-dropzone" v-dropzone="x: moveCard($dropdata, card, list)"></div>
                             <div class="card" v-draggable="x: {card: card, list: list, dragged: \'dragged\'}">
                               <span class="glyphicon glyphicon-pencil pull-right" v-on="click: edit">
                               </span>
                               <component v-html="card.name | marked" v-on="click: showModal = true">
                                 {{card.name}}
                               </component>
                             </div>
                             <modal show="{{true}}" v-if="showModal">
                               <h4 class="modal-title">
                                 {{card.name}}
                               </h4>
                               <div class="modal-body">
                                 <p>Comments: {{card.comments}}</p>
                                 <p>Tags: {{card.tags}}</p>
                                 <p>Members: {{card.members}}</p>
                                 <p>Delete</p>
                                 <p>Archive</p>
                               </div>
                             </modal>'
                  methods:
                    edit: ->
                      @card.oldName = @card.name
                      @toggleCard 'cardForm'
                      @$parent.$parent.isBeingEdited = true
                    moveCard: (drag, dropZone, dropList) ->
                      boardComponent = @$parent.$parent.$parent
                      lists = boardComponent.lists
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
                      boardComponent.updateBoard()
                cardForm:
                  props: ['card', 'toggle-card']
                  template: '<textarea v-model="card.name"
                                       rows="3"
                                       class="form-control mb1 card-input"
                                       v-el="cardname"
                                       @keypress.enter.prevent="save(true)"
                                       @keyup.esc="close"
                                       autofocus>
                             </textarea>
                             <button v-on="click: save(false)" class="btn btn-success mb2">Save</button>
                             <button v-on="click: close" class="btn btn-default mb2">Close</button>'
                  data: ->
                    card: []
                  created: ->
                    Vue.nextTick =>
                      @$$.cardname.focus()
                  methods:
                    close: ->
                      listComponent = @$parent.$parent
                      if @card.oldName?
                        # existing card
                        @card.name = @card.oldName
                        @toggleCard 'cardName'
                      else
                        # newly created card
                        listComponent.list.cards.pop()
                      listComponent.isBeingEdited = false
                    save: (andCreateNext) ->
                      if !!@card.name
                        cardComponent = @$parent
                        listComponent = cardComponent.$parent
                        cards = listComponent.list.cards
                        listComponent.$parent.updateBoard()
                        @toggleCard 'cardName'
                        listComponent.isBeingEdited = false
                        listComponent.createNewCard() if andCreateNext && cardComponent.card.slug == cards[cards.length - 1].slug
                ###cardModal:
                  props: ['card', 'toggle-card']
                  template: '<modal show="{{true}}">
                               <h4 class="modal-title">
                                 {{card.name}}
                               </h4>
                               <div class="modal-body">
                                 <p>Comments: {{card.comments}}</p>
                                 <p>Tags: {{card.tags}}</p>
                                 <p>Members: {{card.members}}</p>
                                 <p>Delete</p>
                                 <p>Archive</p>
                               </div>
                             </modal>'###
    console.log 'Initializing finished'
# Inititalize main component
new App.init