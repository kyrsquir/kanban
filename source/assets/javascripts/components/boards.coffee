Vue.component 'new-board',
  template: '<p class="mt2 mb2 add-link">
               <component is="{{view}}" val="{{board}}" on-done="{{toggle}}"></component>
             </p>'
  data: ->
    view: 'createButton'
  methods:
    toggle: (view, val) ->
      @view = view
  components:
    createButton:
      props: ['val', 'on-done']
      template: '<button v-on="click: edit" class="btn btn-default mb2">Create new board</button>'
      methods:
        edit: ->
          @onDone 'createForm'
    createForm:
      props: ['val', 'on-done']
      template: '<input v-model="val.name" class="form-control mb1" @keypress.enter.prevent="createBoard" @keyup.esc="cancel" autofocus>
                 <button v-on="click: createBoard" class="btn btn-success mb2">Save</button>
                 <button v-on="click: cancel" class="btn btn-default mb2">Close</button>'
      methods:
        createBoard: ->
          name = @val.name
          if !!name
            root = @$parent.$parent
            @$http.post(root.apiURL + '/boards',
                name: name
                background_color: '0079bf'
                lists: []
              (data) ->
                root.boards.push data
                root.setCurrentBoard data
                @onDone 'createButton'
            ).error (data, status, request) ->
              console.log status + ' - ' + request
        cancel: ->
          @onDone 'createButton'