Vue.component 'new-board',
  props: ['boards', 'api', 'set-current-board']
  data: ->
    view: 'newBoardButton'
  template: '<p class="mt2 mb2 add-link">
               <component :is="view" :boards.sync="boards" :api="api" :view.sync="view" :set-current-board="setCurrentBoard"></component>
             </p>'
  components:
    newBoardButton:
      props: ['view']
      template: '<button @click="view = \'newBoardForm\'" class="btn btn-default mb2">Create new board</button>'
    newBoardForm:
      props: ['view', 'boards', 'api', 'set-current-board']
      data: ->
        name: ''
      template: '<div>
                   <input v-model="name" class="form-control mb1" @keypress.enter.prevent="createBoard" @keyup.esc="cancel" v-el:input>
                   <button @click="createBoard" class="btn btn-success mb2">Save</button>
                   <button @click="cancel" class="btn btn-default mb2">Close</button>
                 </div>'
      attached: ->
        @$els.input.focus()
      methods:
        createBoard: ->
          name = @name
          if !!name
            @$http.post(@api + '/boards',
              name: name
              background_color: '0079bf'
              lists: []
              (data) ->
                @boards.push data
                @setCurrentBoard data.id
                @hideForm()
            ).error (data, status, request) ->
              console.log status + ' - ' + request
        hideForm: ->
          @view = 'newBoardButton'
        cancel: ->
          @hideForm()