Vue.component 'modal',
  props: ['card', 'update']
  template: '<div class="modal-mask">
              <div class="modal-wrapper">
                <div class="modal-container">
                  <div class="modal-header" v-if="card">
                    <button type="button" class="close" @click="close">
                      <span aria-hidden="true">×</span>
                    </button>
                    <h4>{{card.name}}</h4>
                    <div>
                      <p>Comments:</p>
                      <comments :comments="card.comments" :update="update"></comments>
                      <p>Tags: {{card.tags}}</p>
                      <p>Members: {{card.members}}</p>
                      <p>Delete</p>
                      <p>Archive</p>
                    </div>
                </div>
              </div>
            </div>'
  methods:
    close: ->
      @$parent.showModal = false