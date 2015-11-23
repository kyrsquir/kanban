Vue.component 'new-board',
  template: '<p class="mt2 mb2 add-link">
               <component :is="view" :board="board" :toggle-board="toggle"></component>
             </p>'
  data: ->
    view: 'createButton'
  methods:
    toggle: (view) ->
      @view = view
  components:
    createButton:
      props: ['board', 'toggle-board']
      template: '<button @click="edit" class="btn btn-default mb2">Create new board</button>'
      methods:
        edit: ->
          @toggleBoard 'createForm'
    createForm:
      props: ['board', 'toggle-board']
      template: '<input v-model="board.name" class="form-control mb1" @keypress.enter.prevent="createBoard" @keyup.esc="cancel" autofocus>
                 <button @click="createBoard" class="btn btn-success mb2">Save</button>
                 <button @click="cancel" class="btn btn-default mb2">Close</button>'
      methods:
        createBoard: ->
          name = @board.name
          if !!name
            root = @$parent.$parent
            @$http.post(root.apiURL + '/boards',
                name: name
                background_color: '0079bf'
                lists: []
              (data) ->
                root.boards.push data
                root.setCurrentBoard data
                @toggleBoard 'createButton'
            ).error (data, status, request) ->
              console.log status + ' - ' + request
        cancel: ->
          @toggleBoard 'createButton'