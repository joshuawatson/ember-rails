// Override the default adapter with the `DS.ActiveModelAdapter` which
// is built to work nicely with the ActiveModel::Serializers gem.
export default DS.ActiveModelAdapter.extend({
  // Adds X-CSRF-Token to all REST requests.
  // Allows for the use of Rails protect_from_forgery
  // The CSRF Token is normally found in app/views/layouts/application.html.*
  // inserted with the rails helper: "csrf_meta_tags"
  headers: {
    "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
  }
});
