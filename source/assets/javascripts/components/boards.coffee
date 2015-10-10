Vue.component 'new-board',
  template: '<p class="mt2 mb2 add-link"><component is="{{view}}" val="{{board}}" on-done="{{toggle}}"></component>Create new board</p><p v-show="show" show="{{@showForm}}"> {{@showForm}} www</p>'
  data:
    showForm: false
    view: 'boardName'
  methods:
    toggle: (view, val) ->
      this.view = view
  props:
    show:
      type: Boolean
      required: true
      twoWay: true
  components:
    boardName:
      props: ['val', 'on-done']
      template: '<p>{{val.name}}</p>'
    boardForm:
      props: ['val', 'on-done']
      template: '<p>Board Form</p>'
      methods:
        create: ->
          this.onDone('formName', this.val)
        cancel: ->
          this.onDone('formName', this.val)

