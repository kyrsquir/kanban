Vue.component 'settings',
  props: ['current-board', 'show-settings', 'update']
  data: ->
    colors: ['0079bf', 'd29034', '519839', 'b04632', '89609e',
             'cd5a91', '4bbf6b', '00aecc', '838c91', '333',
             '202020', '2ecc71', 'ed7669', '272b33']
  template: '<nav v-show="showSettings == true" id="settings" transition="settings">
               <p class="text-center">
                 <strong>Settings</strong>
                 <button type="button" class="close" @click="showSettings = false">
                   <span aria-hidden="true">×</span>
                 </button>
               </p>
               <hr class="dark-divider">
               <p>
                 <label for="board[\'name\']">Board Name</label>
                 <input type="text" v-model="currentBoard.name" class="form-control">
               </p>
               <p>
                 <label>Background Color</label>
               </p>
               <div class="colors mb2">
                 <span v-for="color in colors"
                       class="color-box"
                       v-bind:style="{ backgroundColor: \'#\' + color }"
                       @click="currentBoard.background_color = color">
                 </span>
               </div>
               <button class="btn btn-success btn-block" @click="update">Save</button>
             </nav>'