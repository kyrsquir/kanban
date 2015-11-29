Vue.component 'lists',
  props: ['update', 'lists', 'api', 'user']
  template: '<div class="flexbox">
               <list v-for="list in lists" :list="list" :update="update" :lists="lists" track-by="$index" :api="api" :user="user"></list>
               <article class="list-dropzone" v-dropzone:y="dropList($dropdata)"></article>
               <article>
                 <input type="text"
                        placeholder="Add a list..."
                        class="form-control"
                        v-model="newList"
                        @keyup.enter="addList">
               </article>
             </div>'
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
      props: ['list', 'update', 'lists', 'api', 'user']
      template: '<div class="flexbox">
                   <pre v-show="false">{{ list | json }}</pre>
                   <article class="list-dropzone" v-dropzone:y="moveList($dropdata, list)"></article>
                   <article>
                     <component :is="view"
                                :list="list"
                                :toggle-list="toggle"
                                :update="update">
                     </component>
                     <cards :cards="list.cards" :list="list" :lists="lists" :update="update" :api="api" :user="user"></cards>
                   </article>
                 </div>'
      data: ->
        view: 'listName'
      methods:
        toggle: (view) ->
          formComponentName = 'listForm'
          if view == formComponentName
            for listComponent in @$parent.$children
              if listComponent.view == formComponentName
                for listFormComponent in listComponent.$children
                  listFormComponent.close() if listFormComponent.close?
          @view = view
        moveList: (drag, dropZone) ->
          lists = @lists
          dragIndex = lists.getElementIndex 'slug', drag.list.slug
          dropIndex = lists.getElementIndex 'slug', dropZone.slug
          lists.move dragIndex, dropIndex
          @update()
      components:
        listName:
          props: ['list', 'toggle-list']
          template: '<p class="title" @click="edit" v-draggable:y="{list: list}">{{list.name}}</p>'
          methods:
            edit: ->
              @list.oldName = @list.name
              @toggleList 'listForm'
        listForm:
          props: ['list', 'toggle-list', 'update']
          template: '<div>
                       <input v-model="list.name" class="form-control mb1" @keypress.enter.prevent="save" @keyup.esc="close" v-el:input>
                       <button @click="save" class="btn btn-success mb2">Save</button>
                       <button @click="close" class="btn btn-default mb2">Close</button>
                     </div>'
          attached: ->
            @$els.input.focus()
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