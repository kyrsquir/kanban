Vue.component 'board',
  data: ->
    board: {}
    lists: []
  template: '<list v-repeat="list: lists" track-by="$index" update="{{update}}" lists="{{lists}}"></list>'
  methods:
    update: ->
      console.log 'updated board <', @board.name, '> with lists ', @lists
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

    dropList: (drag) ->
      lists = @lists
      dragPosition = lists.getElementIndex 'slug', drag.list.slug
      lists.push lists.splice(dragPosition, 1)[0]
      @update()