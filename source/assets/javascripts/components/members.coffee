Vue.component 'members',
  props: ['update', 'members', 'api']
  template: '<div>
               <p v-for="member in members" class="title">{{member.name}}</p>
               <new-member :members="members" :update="update" :api="api"></new-member>
             </div>'
  components:
    newMember:
      props: ['members', 'update', 'api']
      data: ->
        view: 'newMemberButton'
      template: '<div>
                   <component :is="view" :members="members" :update="update" :view.sync="view" :api="api"></component>
                 </div>'
      components:
        newMemberButton:
          props: ['view']
          template: '<button @click="view = \'newMemberForm\'" class="btn btn-default mb2">Assign</button>'
        newMemberForm:
          props: ['members', 'view', 'update', 'api']
          data: ->
            searchString: ''
          template: '<div>
                       <div class="form-group">
                         <input v-model="searchString" class="form-control" placeholder="Search members...">
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
              @members.push user
              @update()
              @hideForm()
            hideForm: ->
              @view = 'newMemberButton'