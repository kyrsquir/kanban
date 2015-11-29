Vue.component 'menu-component',
  props: ['set-current-board', 'boards', 'show-menu', 'api']
  data: ->
    searchString: ''
  template: '<nav v-show="showMenu == true" id="boards" transition="boards">
               <p class="text-center">
                 <strong>Boards</strong>
                 <button type="button" class="close" @click="showMenu = false">
                   <span aria-hidden="true">×</span>
                 </button>
               </p>
               <hr class="dark-divider">
               <p class="text-center">
                 {{boards.length}} {{boards.length | pluralize \'board\'}}
               </p>
               <div class="form-group">
                 <input v-model="searchString" class="form-control" placeholder="Search boards...">
               </div>
               <ul class="nav nav-sidebar">
                 <li v-for="board in boards | orderBy \'name\' | filterBy searchString" class="list-unstyled board" track-by="$index">
                   <a href="#" @click="setCurrentBoard(board.id)">
                   <span class="color-box" v-bind:style="{ backgroundColor: \'#\' + board.background_color }"></span>
                     {{board.name}}
                   </a>
                 </li>
               </ul>
               <new-board :boards.sync="boards" :set-current-board="setCurrentBoard" :api="api"></new-board>
             </nav>'