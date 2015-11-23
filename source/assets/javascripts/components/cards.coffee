Vue.component 'cards',
  props: ['cards', 'list', 'lists', 'update']
  template: '<div class="cards">
               <card v-for="card in cards"
                     :add-card="addCard"
                     :card="card"
                     :cards="cards"
                     :list="list"
                     :lists="lists"
                     :update="update"
                     :update-cards-being-edited="updateBeingEdited"
                     track-by="$index">
               </card>
               <div class="card-dropzone" v-dropzone="x: dropCard($dropdata)"></div>
               <p @click="addCard" class="add-link" v-if="!beingEdited">
                 Add new card...
               </p>
             </div>'
  data: ->
    beingEdited: false
  methods:
    addCard: ->
      @cards.push
        name: ''
      children = @$children
      Vue.nextTick =>
        children[children.length - 1].toggle 'cardForm'
        @beingEdited = true
    dropCard: (drag) ->
      dropCards = @cards
      lists = @lists
      dragList = lists[lists.getElementIndex 'slug', drag.list.slug]
      dragCards = dragList.cards
      dragPosition = dragCards.getElementIndex 'slug', drag.card.slug
      dropCards.push dragCards.splice(dragPosition, 1)[0]
      @update()
    updateBeingEdited: (beingEdited) ->
      #TODO remove this, use two-way data binding for beingEdited http://vuejs.org/guide/components.html#Prop_Binding_Types
      @beingEdited = beingEdited
  components:
    card:
      props: ['card', 'cards', 'add-card', 'list', 'lists', 'update', 'update-cards-being-edited']
      template: '<component :is="view"
                            :card="card"
                            :cards="cards"
                            :list="list"
                            :lists="lists"
                            :update-cards-being-edited="updateCardsBeingEdited"
                            :toggle-card="toggle"
                            :add-card="addCard"
                            :update="update"
                            keep-alive>
                 </component>'
      data: ->
        view: 'cardName'
      methods:
        toggle: (view) ->
          if view == 'cardForm'
            for listComponent in @$parent.$parent.$parent.$children
              cardsComponent = listComponent.$children[1]
              if cardsComponent.beingEdited
                for cardComponent in cardsComponent.$children
                  if cardComponent.view == 'cardForm'
                    cardFormComponent = cardComponent.$children[1]
                    cardFormComponent.close()
          @view = view
          #TODO update parent's "being edited" here and don't pass it further to child components
      components:
        cardName:
          props: ['card', 'toggle-card', 'list', 'update', 'lists', 'update-cards-being-edited']
          data: ->
            showModal: false
          template: '<div class="card-dropzone" v-dropzone="x: moveCard($dropdata, card, list)"></div>
                     <div class="card" v-draggable="x: {card: card, list: list, dragged: \'dragged\'}">
                       <span class="glyphicon glyphicon-pencil pull-right" @click="edit"></span>
                       <p @click="showModal = true">{{card.name}}</p>
                     </div>
                     <modal v-show="showModal" :card="card" :update="update"></modal>'
          methods:
            edit: ->
              @card.oldName = @card.name
              @toggleCard 'cardForm'
              @updateCardsBeingEdited true
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
          props: ['card', 'toggle-card', 'update', 'list', 'add-card', 'update-cards-being-edited']
          template: '<textarea v-model="card.name"
                               rows="3"
                               class="form-control mb1 card-input"
                               v-el="cardname"
                               @keypress.enter.prevent="save(true)"
                               @keyup.esc="close"
                               autofocus>
                     </textarea>
                     <button @click="save(false)" class="btn btn-success mb2">Save</button>
                     <button @click="close" class="btn btn-default mb2">Close</button>'
          created: ->
            Vue.nextTick =>
              @$$.cardname.focus()
          methods:
            close: ->
              if @card.oldName?
                # existing card
                @card.name = @card.oldName
                @toggleCard 'cardName'
              else
                # newly created card
                @list.cards.pop()
              @updateCardsBeingEdited false
              delete @card.oldName
            save: (andCreateNext) ->
              if !!@card.name
                @update()
                @toggleCard 'cardName'
                @updateCardsBeingEdited false
                cards = @list.cards
                cardComponent = @$parent
                @addCard() if andCreateNext && cardComponent.card.slug == cards[cards.length - 1].slug
                delete @card.oldName