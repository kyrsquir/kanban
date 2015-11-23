Vue.component 'comments',
  props: ['comments', 'update']
  data: ->
    beingEdited: false
  template: '<comment v-for="comment in comments"
                      :comment="comment"
                      :comments="comments"
                      :id="$index"
                      :update="update"
                      :update-comments-being-edited="updateBeingEdited"
                      track-by="$index">
             </comment>
             <p @click="addComment" class="add-link" v-show="!beingEdited">
               Add a comment
             </p>'
  methods:
    addComment: ->
      @comments.push
        author: @$parent.$parent.$parent.$parent.$parent.$parent.$parent.$parent.currentUser
        text: ''
      children = @$children
      Vue.nextTick =>
        children[children.length - 1].toggle 'commentForm'
    updateBeingEdited: (beingEdited) ->
      #TODO remove this, use two-way data binding for beingEdited http://vuejs.org/guide/components.html#Prop_Binding_Types
      @beingEdited = beingEdited
  components:
    comment:
      props: ['comment', 'comments', 'update', 'update-comments-being-edited']
      data: ->
        view: 'commentName'
      template: '<component :is="view"
                            :comment="comment"
                            :comments="comments"
                            :update="update"
                            :toggle-comment="toggle"
                            track-by="$index">
                 </component>'
      methods:
        toggle: (view) ->
          @updateCommentsBeingEdited (view == 'commentForm')
          @view = view
      components:
        commentName:
          props: ['comment', 'toggle-comment']
          template: '<p class="title" @click="edit">{{comment.author}}: {{comment.text}}</p>'
          methods:
            edit: ->
              @comment.oldText = @comment.text
              @toggleComment 'commentForm'
        commentForm:
          props: ['comment', 'comments', 'update', 'toggle-comment']
          template: '<input v-model="comment.text"
                        class="form-control mb1"
                        v-el="commentNameInput"
                        @keypress.enter.prevent="save"
                        @keyup.esc="close"
                        autofocus>
                 <button @click="save" class="btn btn-success mb2">Save</button>
                 <button @click="close" class="btn btn-default mb2">Close</button>'
          methods:
            close: ->
              @toggleComment 'commentName'
              if @comment.oldText?
                # existing comment
                @comment.text = @comment.oldText
              else
                # newly created comment
                @comments.pop()
              delete @comment.oldText

            save: ->
              if !!@comment.text
                @update()
                @toggleComment 'commentName'
                delete @comment.oldText


