(function() {
  var mic_component;

  mic_component = {
    props: ['val'],
    template: '<component is="{{view}}" val="{{val}}" on-done="{{toggle}}" keep-alive></component>',
    data: {
      view: 'name'
    },
    methods: {
      toggle: function(view, val) {
        return this.view = view;
      }
    }
  };

  Vue.extend('name', {
    props: ['val', 'on-done'],
    template: "<strong v-on='click: edit'>{{ val.name }}</strong>",
    methods: {
      edit: function() {
        return this.onDone('form');
      }
    }
  });

  Vue.extend('form', {
    props: ['val', 'on-done'],
    template: "<input v-model='val.name'</input> <button v-on='click: close'>close</button>",
    data: {
      val: []
    },
    methods: {
      close: function() {
        return this.onDone('name', this.val);
      }
    }
  });

}).call(this);
