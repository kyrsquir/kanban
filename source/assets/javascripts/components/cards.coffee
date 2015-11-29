Vue.component 'cards',
  props: ['cards', 'list', 'lists', 'update', 'api', 'user']
  data: ->
    editingCards: false
  template: '<div class="cards">
               <card v-for="card in cards"
                     :add-card="addCard"
                     :card="card"
                     :cards="cards"
                     :list="list"
                     :lists="lists"
                     :update="update"
                     :api="api"
                     :user="user"
                     :editing-cards.sync="editingCards"
                     track-by="$index">
               </card>
               <div class="card-dropzone" v-dropzone:x="dropCard($dropdata)"></div>
               <p @click="addCard" class="add-link" v-show="editingCards == false">Add new card</p>
             </div>'
  methods:
    addCard: ->
      @cards.push
        name: ''
      children = @$children
      Vue.nextTick =>
        children[children.length - 1].toggle 'cardForm'
    dropCard: (drag) ->
      dropCards = @cards
      lists = @lists
      dragList = lists[lists.getElementIndex 'slug', drag.list.slug]
      dragCards = dragList.cards
      dragPosition = dragCards.getElementIndex 'slug', drag.card.slug
      dropCards.push dragCards.splice(dragPosition, 1)[0]
      @update()
  components:
    card:
      props: ['card', 'add-card', 'list', 'lists', 'update', 'editing-cards', 'api', 'user']
      data: ->
        view: 'cardName'
      template: '<div>
                   <component :is="view"
                              :card="card"
                              :list="list"
                              :lists="lists"
                              :toggle-card="toggle"
                              :add-card="addCard"
                              :update="update"
                              :api="api"
                              :user="user"
                              keep-alive>
                   </component>
                 </div>'
      methods:
        toggle: (view) ->
          formComponentName = 'cardForm'
          if view == formComponentName
            @editingCards = true
            for listComponent in @$parent.$parent.$parent.$children
              cardsComponent = listComponent.$children[1]
              if cardsComponent.editingCards
                for cardComponent in cardsComponent.$children
                  if cardComponent.view == formComponentName
                    cardFormComponent = cardComponent.$children[1]
                    cardFormComponent.close()
          else
            @editingCards = false
          @view = view
      components:
        cardName:
          props: ['card', 'toggle-card', 'list', 'update', 'lists', 'api', 'user']
          data: ->
            showModal: false
          template: '<div>
                       <div class="card-dropzone" v-dropzone:x="moveCard($dropdata, card, list)"></div>
                       <div class="card" v-draggable:x="{card: card, list: list, dragged: \'dragged\'}">
                         <span class="glyphicon glyphicon-pencil pull-right" @click="edit"></span>
                         <p @click="showModal = true">{{card.name}}</p>
                       </div>
                       <modal v-show="showModal == true" :card="card" :update="update" :api="api" :user="user" :show-modal.sync="showModal"></modal>
                     </div>'
          methods:
            edit: ->
              @card.oldName = @card.name
              @toggleCard 'cardForm'
            moveCard: (drag, dropZone, dropList) ->
              lists = @lists
              dragListId = drag.list.slug
              dropListId = dropList.slug
              dragList = lists[lists.getElementIndex 'slug', dragListId]
              dragListCards = dragList.cards
              dropListCards = dropList.cards
              dragPosition = dragListCards.getElementIndex 'slug', drag.card.slug
              dropPosition = dropListCards.getElementIndex 'slug', dropZone.slug
              if dragListId == dropListId
                dragListCards.move dragPosition, dropPosition
              else
                dropListCards.splice dropPosition, 0, dragListCards.splice(dragPosition, 1)[0]
              @update()
        cardForm:
          props: ['card', 'toggle-card', 'update', 'list', 'add-card']
          template: '<div>
                       <textarea v-model="card.name"
                                 rows="3"
                                 class="form-control mb1 card-input"
                                 @keypress.enter.prevent="save(true)"
                                 @keyup.esc="close"
                                 v-el:textarea>
                       </textarea>
                       <button @click="save(false)" class="btn btn-success mb2">Save</button>
                       <button @click="close" class="btn btn-default mb2">Close</button>
                     </div>'
          attached: ->
            @$els.textarea.focus()
          methods:
            close: ->
              if @card.oldName?
                @card.name = @card.oldName
              else
                @list.cards.pop()
              @toggleCard 'cardName'
              delete @card.oldName
            save: (andCreateNext) ->
              if !!@card.name
                @update()
                @toggleCard 'cardName'
                cards = @list.cards
                cardComponent = @$parent
                @addCard() if andCreateNext && cardComponent.card.slug == cards[cards.length - 1].slug
                delete @card.oldName