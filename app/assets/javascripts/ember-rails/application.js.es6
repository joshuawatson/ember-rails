//= require ember-rails/loader
//= require ember-rails/register_ember
//= require ember-rails/ember-resolver
//= require ember-rails/ember-load-initializers
//
//= require ember-rails/module_prefix

import Ember from 'ember';
import Resolver from 'ember/resolver';
import loadInitializers from 'ember/load-initializers';
import modulePrefix from 'ember-rails/module_prefix';

var App = Ember.Application.extend({
  modulePrefix: modulePrefix,
  Resolver: Resolver
});

loadInitializers(App, modulePrefix);

export default App;
