(function() {
  var App, mic_component;

  App = {
    init: function() {
      var lists;
      console.log("Initializing");
      return lists = new Vue({
        el: "body",
        data: {
          board: {
            name: 'Kanban',
            backgroundColor: '519839'
          },
          newList: '',
          showListForm: false,
          showSettings: false,
          lists: [
            {
              id: 1,
              name: "List1",
              cards: [
                {
                  id: 1,
                  name: 'Card A'
                }, {
                  id: 2,
                  name: 'Card B'
                }
              ]
            }, {
              id: 2,
              name: "List2",
              cards: [
                {
                  id: 3,
                  name: 'Card C'
                }
              ]
            }, {
              id: 3,
              name: "List3",
              cards: [
                {
                  id: 4,
                  name: 'Card D'
                }, {
                  id: 5,
                  name: 'Card E'
                }, {
                  id: 6,
                  name: 'Card F'
                }
              ]
            }, {
              id: 4,
              name: "List4",
              cards: []
            }, {
              id: 5,
              name: "List5",
              cards: []
            }, {
              id: 6,
              name: "List6",
              cards: []
            }
          ],
          colors: ['0079bf', 'd29034', '519839', 'b04632', '89609e', 'cd5a91', '4bbf6b', '00aecc', '838c91', '333', '202020', '2ecc71', 'ed7669', '272b33']
        },
        methods: {
          toggleList: function() {
            console.log("clicked");
            return this.showListForm = !this.showListForm;
          },
          toggle: function(list) {
            list.name = list.id + " " + list.name;
            return console.log(list.name);
          },
          toggleListForm: function() {
            listForm === 'true';
            return console.log(listForm);
          },
          toggleSettings: function() {
            this.showSettings = !this.showSettings;
            return false;
          },
          changeBackground: function(color) {
            return this.board.backgroundColor = color;
          },
          addList: function() {
            var value;
            console.log(this.newList);
            value = this.newList.replace(/^\s+|\s+$/g, "");
            this.lists.push({
              name: value,
              cards: []
            });
            return this.newList = '';
          },
          saveList: function() {
            var value;
            value = this.list.name.trim();
            return console.log(value);
          },
          addCard: function(list) {
            var value;
            value = "test";
            return list.cards.push({
              name: value
            });
          }
        },
        components: {
          list: {
            props: ['val'],
            template: '<component is="{{view}}" val="{{val}}" on-done="{{toggle}}" keep-alive></component>',
            data: function() {
              return {
                view: 'listName'
              };
            },
            methods: {
              toggle: function(view, val) {
                return this.view = view;
              }
            }
          },
          listName: {
            props: ['val', 'on-done'],
            template: "<p v-on='click: edit' class='title'>{{ val.name }}</p>",
            methods: {
              edit: function() {
                return this.onDone('listForm');
              }
            }
          },
          listForm: {
            props: ['val', 'on-done'],
            template: "<input v-model='val.name' class='form-control mb1' autofocus> <button v-on='click: save' class='btn btn-success mb2'>Save</button> <button v-on='click: close' class='btn btn-default mb2'>Close</button>",
            data: function() {
              return {
                val: []
              };
            },
            methods: {
              close: function() {
                var original_name;
                original_name = this.val.name;
                console.log(this.val.name);
                this.onDone('listName', original_name);
                return console.log(original_name);
              },
              save: function() {
                return this.onDone('listName', this.val);
              }
            }
          },
          card: {
            props: ['val'],
            template: '<component is="{{view}}" val="{{val}}" on-done="{{toggle}}" keep-alive></component>',
            data: function() {
              return {
                view: 'cardName'
              };
            },
            methods: {
              toggle: function(view, val) {
                return this.view = view;
              }
            }
          },
          cardName: {
            props: ['val', 'on-done'],
            template: "<div v-html='val.name | marked' v-on='click: edit' class='card'></div>",
            methods: {
              edit: function() {
                return this.onDone('cardForm');
              }
            }
          },
          cardForm: {
            props: ['val', 'on-done'],
            template: "<textarea v-model='val.name' rows='3' class='form-control mb1 card-input' autofocus></textarea> <button v-on='click: save' class='btn btn-success mb2'>Save</button> <button v-on='click: close' class='btn btn-default mb2'>Close</button>",
            data: function() {
              return {
                val: []
              };
            },
            methods: {
              close: function() {
                return this.onDone('cardName', this.val);
              },
              save: function() {
                return this.onDone('cardName', this.val);
              }
            }
          }
        },
        filters: {
          marked: marked
        }
      });
    }
  };

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

  new App.init;

}).call(this);
