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
    for i in [VueResource, VueDnd]
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
        api: 'https://api-kanban.herokuapp.com/api'
        boards: []
        currentBoard: {}
        showMenu: false
        showSettings: false
        currentUser: 'testUser'

      methods:
        getBoards: ->
          @$http.get @api + '/boards', (data) ->
            @$set 'boards', data
            @setCurrentBoard data[0].id
          .error (data, status, request) ->
            console.log status + ' - ' + request
        setCurrentBoard: (id) ->
          @$http.get @api + '/boards/' + id, (boardData) ->
            @currentBoard = boardData
            for list in boardData.lists
              if list.cards.length > 0
                for card in list.cards
                  card.comments = []
                  card.comments.push
                    author: @currentUser
                    text: 'example comment 1'
                  card.comments.push
                    author: @currentUser
                    text: 'example comment 2'
            @showMenu = false
        updateCurrentBoard: ->
          currentBoard = @currentBoard
          @$http.put(@api + '/boards/' + currentBoard.id,
            name: currentBoard.name
            background_color: currentBoard.background_color
            lists: currentBoard.lists
            (data, status, request) ->
              console.log 'Successfully updated board <' + currentBoard.name + '>'
              @showSettings = false
          ).error (data, status, request) ->
            console.log status + ' - ' + request
# Inititalize main component
new App.init
