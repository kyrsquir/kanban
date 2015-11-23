Vue.component 'board',
  data: ->
    board: {}
  template: '<lists :update="update" :lists="board.lists"></lists>'
  methods:
    update: ->
      console.log 'updated board <', @board.name, '> with lists ', JSON.stringify @lists
      @$http.put(@$parent.apiURL + '/boards/' + @board.id,
          name: @board.name
          background_color: @board.background_color
          lists: @lists
        (data, status, request) ->
          console.log status + ' - ' + request
      ).error (data, status, request) ->
        console.log status + ' - ' + request
    save: ->
      @update()
      @$parent.toggleSettings()