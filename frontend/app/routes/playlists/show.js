import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    setIsSyncingPlaylist(val){
      console.log("setIsSyncingPlaylist val: " + val);
      this.get('controller').set('isSyncingPlaylist', val);
    },
    transitionAfterDelete(){
      let playlist = this.store.findAll('playlist').then((playlists) => {
        let id = playlists.objectAt(playlists.get('length')-1).get('id');
        this.transitionTo('playlists.show', id);
      });
    }
  },
  setupController(controller, model){
    this._super(controller, model);
    controller.set('isSyncingPlaylist', false);
  },
  model(params) {
    return Ember.RSVP.hash({
      playlist: this.store.findRecord('playlist', params.id),
      tracks: this.store.findAll('track'),
      playlists: this.store.findAll('playlist'),
      labels: this.store.findAll('label')
    });
  }
});
