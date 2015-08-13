(function() {
  var App;

  App = {
    init: function() {
      var apiURL, boardsURL, i, j, len, ref;
      console.log("Initializing");
      ref = [VueResource, VueDnd];
      for (j = 0, len = ref.length; j < len; j++) {
        i = ref[j];
        Vue.use(i);
      }
      Vue.config.debug = true;
      Vue.http.headers.common['Content-type'] = 'application/json';
      Vue.http.headers.common['Authorization'] = 'Token token="111"';
      apiURL = "https://projects-api.herokuapp.com/api";
      boardsURL = apiURL + '/boards';
      return new Vue({
        el: "body",
        ready: function() {
          return this.getBoards();
        },
        data: {
          boards: [],
          currentBoard: {},
          lists: [],
          showSettings: false,
          showBoards: false,
          showModal: false,
          colors: ['0079bf', 'd29034', '519839', 'b04632', '89609e', 'cd5a91', '4bbf6b', '00aecc', '838c91', '333', '202020', '2ecc71', 'ed7669', '272b33']
        },
        methods: {
          toggleSettings: function() {
            return this.showSettings = !this.showSettings;
          },
          toggleBoards: function() {
            return this.showBoards = !this.showBoards;
          },
          changeBackground: function(color) {
            return this.currentBoard.background_color = color;
          },
          saveBoard: function() {
            var boardURL;
            boardURL = apiURL + '/boards/' + this.currentBoard.id;
            this.$http.put(boardURL, {
              name: this.currentBoard.name,
              background_color: this.currentBoard.background_color
            }, function(data, status, request) {}).error(function(data, status, request) {
              return console.log(status + ' - ' + request);
            });
            return this.toggleSettings();
          },
          setCurrentBoard: function(board) {
            this.currentBoard = board;
            return this.lists = board.lists;
          },
          getBoards: function() {
            return this.$http.get(boardsURL, function(data, status, request) {
              this.$set('boards', data);
              this.$set('currentBoard', data[1]);
              return this.$set('lists', data[1].lists);
            }).error(function(data, status, request) {
              return console.log(status + ' - ' + request);
            });
          },
          addList: function() {
            var currentBoardURL, value;
            console.log(this.newList);
            value = this.newList.replace(/^\s+|\s+$/g, "");
            this.lists.push({
              name: value,
              position: 10
            });
            this.newList = '';
            currentBoardURL = boardsURL + '/' + this.currentBoard.id;
            return this.$http.put(currentBoardURL, {
              lists: this.lists
            }, function(data, status, request) {}).error(function(data, status, request) {
              return console.log(status + ' - ' + request);
            });
          },
          saveList: function() {
            var value;
            value = this.list.name.trim();
            return console.log(value);
          },
          sort: function(list, id, tag, data) {
            var tmp;
            console.log(list, data);
            tmp = list[data.index];
            console.log(tmp, data.index);
            list.splice(data.index, 1);
            return list.splice(id, 0, tmp);
          },
          move: function() {
            return console.log('moving');
          }
        },
        components: {
          list: {
            template: '<article><component is="{{view}}" val="{{list}}" on-done="{{toggle}}"></component> <div class="cards"> <card v-repeat="card: list.cards | orderBy \'position\'" class="cards"></card> <p v-on="click: showCreate" class="add-card" v-if="!enter"> Add a card... </p> </div> </article>',
            data: function() {
              return {
                view: 'listName'
              };
            },
            methods: {
              toggle: function(view, val) {
                return this.view = view;
              },
              showCreate: function() {
                var lastItem, position;
                position = 0;
                if (this.list.cards.length > 0) {
                  lastItem = this.list.cards[this.list.cards.length - 1];
                  position = lastItem.position;
                }
                return this.list.cards.push({
                  name: "New",
                  position: position++
                });
              }
            },
            components: {
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
                template: "<input v-model='val.name' class='form-control mb1' v-el='listname'> <button v-on='click: save' class='btn btn-success mb2'>Save</button> <button v-on='click: close' class='btn btn-default mb2'>Close</button>",
                created: function() {
                  console.log('out');
                  return Vue.nextTick((function(_this) {
                    return function() {
                      return _this.$$.listname.focus();
                    };
                  })(this));
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
                    console.log('list saved');
                    return this.onDone('listName', this.val);
                  }
                }
              },
              card: {
                template: '<component is="{{view}}" val="{{card}}" on-done="{{toggle}}" keep-alive></component>',
                data: function() {
                  return {
                    view: 'cardName'
                  };
                },
                methods: {
                  toggle: function(view, val) {
                    return this.view = view;
                  }
                },
                components: {
                  cardName: {
                    filters: {
                      marked: marked
                    },
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
                        console.log('card saved');
                        return this.onDone('cardName', this.val);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      });
    }
  };

  new App.init;

}).call(this);
