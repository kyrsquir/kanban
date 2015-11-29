Vue.component 'members',
  props: ['members', 'update', 'api']
  data: ->
    view: 'newMemberButton'
  template: '<div>
               <p class="title" v-for="member in members">{{member.name}}</p>
               <component :is="view" :members.sync="members" :update="update" :view.sync="view" :api="api"></component>
             </div>'
  components:
    newMemberButton:
      props: ['view', 'members']
      template: '<div>
                   <button v-show="members.length == 0" @click="view = \'newMemberForm\'" class="btn btn-default mb2">Assign</button>
                   <div v-show="members.length > 0">
                     <button @click="view = \'newMemberForm\'" class="btn btn-default mb2">Change</button>
                     <button @click="members = []" class="btn btn-default mb2">Remove</button>
                   </div>
                 </div>'
    newMemberForm:
      props: ['members', 'view', 'update', 'api']
      data: ->
        searchString: ''
      template: '<div>
                   <div class="form-group">
                     <input v-model="searchString" class="form-control" placeholder="Search users...">
                   </div>
                   <ul class="nav nav-sidebar" v-if="!!searchString">
                     <li v-for="user in users | orderBy name | filterBy searchString" class="list-unstyled board" track-by="$index">
                       <a href="#" @click="assignUser(user)">{{user.name}}</a>
                     </li>
                   </ul>
                   <button @click="close" class="btn btn-default mb2">Close</button>
                 </div>'
      attached: ->
        @$http.get(@api + '/users',
          (data, status, request) ->
            @users = data
        ).error (data, status, request) ->
          console.log status + ' - ' + request
      methods:
        close: ->
          @hideForm()
        assignUser: (user) ->
          if @members.length > 0
            @members.pop()
          @members.push user
          @update()
          @hideForm()
        hideForm: ->
          @view = 'newMemberButton'