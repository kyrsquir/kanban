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
        apiURL: 'https://api-kanban.herokuapp.com/api'
        boards: []
        currentBoard: {}
        showSettings: false
        showMenu: false
        showModal: false
        colors: ['0079bf', 'd29034', '519839', 'b04632', '89609e',
                 'cd5a91', '4bbf6b', '00aecc', '838c91', '333',
                 '202020', '2ecc71', 'ed7669', '272b33']
        currentUser: 'testUser'
        searchString: ''

      methods:
        toggleSettings: ->
          @showSettings = !@showSettings

        toggleMenu: ->
          @showMenu = !@showMenu

        changeBackground: (color) ->
          @currentBoard.background_color = color

        getBoards: ->
          @$http.get @apiURL + '/boards', (data) ->
            @$set 'boards', data
            @setCurrentBoard data[0].id
          .error (data, status, request) ->
            console.log status + ' - ' + request

        setCurrentBoard: (id) ->
          @$http.get @apiURL + '/boards/' + id, (boardData) ->
            boardComponent = @$children[1]
            @currentBoard = boardComponent.board = boardData
            for list in boardData.lists
              if list.cards.length > 0
                for card in list.cards
                  card.comments = []
                  card.comments.push
                    author: @currentUser
                    text: 'comment 1 text'
                  card.comments.push
                    author: @currentUser
                    text: 'comment 2 text'
            boardComponent.lists = boardData.lists
            @showMenu = false

        #TODO create settings component and move it there
        saveBoardSettings: ->
          @$children[1].save()
# Inititalize main component
new App.init
