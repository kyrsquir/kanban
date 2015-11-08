Vue.component 'modal',
  template: '#modal-template'
  props:
    show:
      type: Boolean
      required: true
      twoWay: true
  methods:
    close: ->
      @$parent.showModal = false