Vue.component 'card',
  template: '<component :is="view"
                        card="{{card}}"
                        cards="{{cards}}"
                        list="{{list}}"
                        lists="{{lists}}"
                        set-being-edited="{{setBeingEdited}}"
                        toggle-card="{{toggle}}"
                        add-card="{{addCard}}"
                        update="{{update}}"
                        keep-alive>
             </component>'
  inherit: true
  data: ->
    view: 'cardName'
  methods:
    toggle: (view) ->
      if view == 'cardForm'
        for component in @$parent.$parent.$children
          if component.isBeingEdited
            for childComponent in component.$children
              if childComponent.view == 'cardForm'
                childComponent.$children[1].close()
      @view = view
  # child components of card
  components:
    cardName:
      filters:
        marked: marked
      props: ['card', 'toggle-card', 'list', 'update', 'lists', 'set-being-edited']
      data: ->
        showModal: false #TODO move modal to root card component
      template: '<div class="card-dropzone" v-dropzone="x: moveCard($dropdata, card, list)"></div>
                 <div class="card" v-draggable="x: {card: card, list: list, dragged: \'dragged\'}">
                   <span class="glyphicon glyphicon-pencil pull-right" v-on="click: edit">
                   </span>
                   <component v-html="card.name | marked" v-on="click: showModal = true">
                     {{card.name}}
                   </component>
                 </div>
                 <modal show="{{true}}" v-if="showModal">
                   <h4 class="modal-title">
                     {{card.name}}
                   </h4>
                   <div class="modal-body">
                     <p>Comments: {{card.comments}}</p>
                     <p>Tags: {{card.tags}}</p>
                     <p>Members: {{card.members}}</p>
                     <p>Delete</p>
                     <p>Archive</p>
                   </div>
                 </modal>'
      methods:
        edit: ->
          @card.oldName = @card.name
          @toggleCard 'cardForm'
          @setBeingEdited true
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
      props: ['card', 'toggle-card', 'update', 'list', 'add-card', 'set-being-edited']
      template: '<textarea v-model="card.name"
                           rows="3"
                           class="form-control mb1 card-input"
                           v-el="cardname"
                           @keypress.enter.prevent="save(true)"
                           @keyup.esc="close"
                           autofocus>
                 </textarea>
                 <button v-on="click: save(false)" class="btn btn-success mb2">Save</button>
                 <button v-on="click: close" class="btn btn-default mb2">Close</button>'
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
          @setBeingEdited false
        save: (andCreateNext) ->
          if !!@card.name
            cardComponent = @$parent
            cards = @list.cards
            @update()
            @toggleCard 'cardName'
            @setBeingEdited false
            @addCard() if andCreateNext && cardComponent.card.slug == cards[cards.length - 1].slug