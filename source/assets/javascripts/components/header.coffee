Vue.component 'header-component',
  props: ['show-settings', 'show-menu', 'current-board']
  template: '<nav class="navbar navbar-inverse navbar-fixed-top main-nav">
               <div class="container-fluid">
                 <div class="navbar-header">
                   <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                     <span class="sr-only">Toggle navigation</span>
                     <span class="icon-bar"></span>
                     <span class="icon-bar"></span>
                     <span class="icon-bar"></span>
                   </button>
                   <a class="navbar-brand" href="#">{{currentBoard.name}}</a>
                 </div>
                 <ul class="nav navbar-nav">
                   <li><a href="#" @click="showMenu = !showMenu">Boards</a></li>
                 </ul>
                 <nav class="collapse navbar-collapse">
                   <ul class="nav navbar-nav navbar-right">
                     <li><a href="#" @click="showSettings = !showSettings"><span class="glyphicon glyphicon-cog"></span></a></li>
                   </ul>
                 </nav>
               </div>
             </nav>'