# Vue.use 'vue-element'


mic_component =
  props: ['val'],
  template: '<component is="{{view}}" val="{{val}}" on-done="{{toggle}}" keep-alive></component>',
  data:
    view: 'name',
  methods:
    toggle: (view, val) ->
      this.view = view

Vue.extend 'name',
  props: ['val', 'on-done'],
  template: "<strong v-on='click: edit'>{{ val.name }}</strong>",
  methods:
    edit: ->
      this.onDone('form')

Vue.extend 'form',
  props: ['val', 'on-done'],
  template: "<input v-model='val.name'</input> <button v-on='click: close'>close</button>",
  data:
    val: [],
  methods:
    close: ->
      this.onDone('name', this.val)
