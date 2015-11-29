Vue.component 'comments',
  props: ['comments', 'update', 'user']
  data: ->
    editingComments: false
  template: '<div>
               <comment v-for="comment in comments"
                        :comment="comment"
                        :comments="comments"
                        :id="$index"
                        :update="update"
                        :editing-comments.sync="editingComments"
                        track-by="$index">
               </comment>
               <button @click="addComment" class="btn btn-default mb2" v-show="editingComments == false">Add a comment</button>
             </div>'
  methods:
    addComment: ->
      @comments.push
        author: @user
        text: ''
      children = @$children
      Vue.nextTick =>
        children[children.length - 1].toggle 'commentForm'
  components:
    comment:
      props: ['comment', 'comments', 'update', 'editing-comments']
      data: ->
        view: 'commentName'
      template: '<div>
                   <component :is="view"
                              :comment="comment"
                              :comments="comments"
                              :update="update"
                              :toggle-comment="toggle"
                              track-by="$index">
                   </component>
                 </div>'
      methods:
        toggle: (view) ->
          formComponentName = 'commentForm'
          if view == formComponentName
            @editingComments = true
            for commentComponent in @$parent.$children
              if commentComponent.view == formComponentName
                for commentFormComponent in commentComponent.$children
                  commentFormComponent.close()
          else
            @editingComments = false
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
          template: '<div>
                       <input v-model="comment.text"
                          class="form-control mb1"
                          @keypress.enter.prevent="save"
                          @keyup.esc="close"
                          v-el:input>
                       <button @click="save" class="btn btn-success mb2">Save</button>
                       <button @click="close" class="btn btn-default mb2">Close</button>
                     </div>'
          attached: ->
            @$els.input.focus()
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


