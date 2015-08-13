(function() {
  Vue.component('modal', {
    template: '#modal-template',
    props: {
      show: {
        type: Boolean,
        required: true,
        twoWay: true
      }
    }
  });

}).call(this);
