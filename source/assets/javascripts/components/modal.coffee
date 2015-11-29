Vue.component 'modal',
  props: ['card', 'update', 'api', 'user', 'show-modal']
  template: '<div class="modal-mask">
              <div class="modal-wrapper">
                <div class="modal-container">
                  <div class="modal-header" v-if="card">
                    <button type="button" class="close" @click="showModal = false">
                      <span aria-hidden="true">×</span>
                    </button>
                    <h4>{{card.name}}</h4>
                    <p>Comments:</p>
                    <comments :comments="card.comments" :update="update" :user="user"></comments>
                    <p>Tags: {{card.tags}}</p>
                    <p>Assignee:</p>
                    <members :members="card.members" :update="update" :api="api"></members>
                    <p>Actions:</p>
                    <button class="btn btn-default mb2">Delete</button>
                    <button class="btn btn-default mb2">Archive</button>
                </div>
              </div>
            </div>'