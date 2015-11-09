Vue.component 'list',
  template: '<pre>{{ list | json }}</pre>
             <article class="list-dropzone" v-dropzone="y: moveList($dropdata, list)"></article>
             <article>
               <component :is="view"
                          list="{{list}}"
                          cards="{{list.cards}}"
                          toggle-list="{{toggle}}"
                          update="{{update}}"
                          set-being-edited="{{setBeingEdited}}"
                          add-card="{{addCard}}">
               </component>
               <div class="cards">
                 <card v-repeat="card: list.cards" track-by="$index"></card>
                 <div class="card-dropzone" v-dropzone="x: dropCard($dropdata)"></div>
                 <p v-on="click: addCard" class="add-link" v-if="!isBeingEdited">
                   Add new card...
                 </p>
               </div>
             </article>'
  props: ['update', 'lists']
  data: ->
    isBeingEdited: false
    view: 'listName'
  methods:
    toggle: (view) ->
      @view = view
    addCard: ->
      @list.cards.push
        name: ''
      children = @$children
      Vue.nextTick =>
        children[children.length - 1].toggle 'cardForm'
        @setBeingEdited true
    setBeingEdited: (boolean) ->
      @isBeingEdited = boolean
    moveList: (drag, dropZone) ->
      lists = @lists
      dragIndex = lists.getElementIndex 'slug', drag.list.slug
      dropIndex = lists.getElementIndex 'slug', dropZone.slug
      lists.move dragIndex, dropIndex
      @update()
    dropCard: (drag) ->
      dropCards = @list.cards
      lists = @lists
      dragList = lists[lists.getElementIndex 'slug', drag.list.slug]
      dragCards = dragList.cards
      dragPosition = dragCards.getElementIndex 'slug', drag.card.slug
      dropCards.push dragCards.splice(dragPosition, 1)[0]
      @update()
  # child components for list
  components:
    listName:
      props: ['list', 'toggle-list']
      template: '<p class="title" v-on="click: edit" v-draggable="y: {list: list}">{{list.name}}</p>'
      methods:
        edit: ->
          @list.oldName = @list.name
          @toggleList 'listForm'
    listForm:
      props: ['list', 'toggle-list', 'update']
      template: '<input v-model="list.name" class="form-control mb1" v-el="listNameInput" @keypress.enter.prevent="save" @keyup.esc="close" autofocus>
                 <button v-on="click: save" class="btn btn-success mb2">Save</button>
                 <button v-on="click: close" class="btn btn-default mb2">Close</button>'
      created: ->
        Vue.nextTick =>
          @$$.listNameInput.focus()
      methods:
        close: ->
          @list.name = @list.oldName
          @toggleList 'listName'
        save: ->
          console.log 'asdfasdf'
          if !!@list.name
            @update()
            @toggleList 'listName'