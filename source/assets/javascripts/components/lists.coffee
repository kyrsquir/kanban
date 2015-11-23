Vue.component 'lists',
  props: ['update', 'lists']
  template: '<list v-for="list in lists" :list="list" :update="update" :lists="lists" track-by="$index"></list>
             <article class="list-dropzone" v-dropzone="y: dropList($dropdata)"></article>
             <article>
               <input type="text"
                      placeholder="Add a list..."
                      class="form-control"
                      v-model="newList"
                      @keyup.enter="addList">
             </article>'
  methods:
    dropList: (drag) ->
      lists = @lists
      dragPosition = lists.getElementIndex 'slug', drag.list.slug
      lists.push lists.splice(dragPosition, 1)[0]
      @update()
    addList: ->
      value = @newList.replace /^\s+|\s+$/g, ""
      @lists.push
        name: value
        active: false
        cards: []
      @newList = ''
      @update()
  components:
    list:
      props: ['list', 'update', 'lists']
      template: '<pre v-show="false">{{ list | json }}</pre>
                 <article class="list-dropzone" v-dropzone="y: moveList($dropdata, list)"></article>
                 <article>
                   <component :is="view"
                              :list="list"
                              :toggle-list="toggle"
                              :update="update">
                   </component>
                   <cards :cards="list.cards" :list="list" :lists="lists" :update="update"></cards>
                 </article>'
      data: ->
        view: 'listName'
      methods:
        toggle: (view) ->
          @view = view
        moveList: (drag, dropZone) ->
          lists = @lists
          dragIndex = lists.getElementIndex 'slug', drag.list.slug
          dropIndex = lists.getElementIndex 'slug', dropZone.slug
          lists.move dragIndex, dropIndex
          @update()
      # child components for list
      components:
        listName:
          props: ['list', 'toggle-list']
          template: '<p class="title" @click="edit" v-draggable="y: {list: list}">{{list.name}}</p>'
          methods:
            edit: ->
              @list.oldName = @list.name
              @toggleList 'listForm'
        listForm:
          props: ['list', 'toggle-list', 'update']
          template: '<input v-model="list.name" class="form-control mb1" v-el="listNameInput" @keypress.enter.prevent="save" @keyup.esc="close" autofocus>
                     <button @click="save" class="btn btn-success mb2">Save</button>
                     <button @click="close" class="btn btn-default mb2">Close</button>'
          created: ->
            Vue.nextTick =>
              @$$.listNameInput.focus()
          methods:
            close: ->
              @list.name = @list.oldName
              @toggleList 'listName'
              delete @list.oldName
            save: ->
              if !!@list.name
                @update()
                @toggleList 'listName'
                delete @list.oldName