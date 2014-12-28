require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test "page header should include link to asset" do
    get :index
    assert_response :success
    assert_select 'head script[src="/assets/templates/test.js"]', true, @response.body
  end

end

class HjsTemplateTest < IntegrationTest

  def handlebars
    Rails.configuration.handlebars
  end

  def with_template_root(root, sep=nil)
    old, handlebars.templates_root = handlebars.templates_root, root

    if sep
      old_sep, handlebars.templates_path_separator = handlebars.templates_path_separator, sep
    end

    yield
  ensure
    handlebars.templates_root = old
    handlebars.templates_path_separator = old_sep if sep
  end

  def with_amd_output
    old, handlebars.output_type = handlebars.output_type, :amd
    old_namespace, handlebars.amd_namespace = handlebars.amd_namespace, 'appkit'

    yield
  ensure
    handlebars.output_type = old
    handlebars.amd_namespace = old_namespace
  end

  def with_ember_template(template)
    old, handlebars.ember_template = handlebars.ember_template, template

    yield
  ensure
    handlebars.ember_template = old
  end

  test "should replace separators with templates_path_separator" do
    with_template_root("", "-") do
      t = Ember::Handlebars::Template.new {}
      path = t.send(:template_path, 'app/templates/example')
      assert_equal path, 'app-templates-example'
    end
  end

  test "should strip only first occurence of templates_root" do
    with_template_root("app", "/") do
      t = Ember::Handlebars::Template.new {}
      path = t.send(:template_path, 'app/templates/app/example')
      assert_equal path, 'templates/app/example'
    end
  end

  test "should strip templates_root with / in it" do
    with_template_root("app/templates") do
      t = Ember::Handlebars::Template.new {}
      path = t.send(:template_path, 'app/templates/app/example')
      assert path == 'app/example', path
    end
  end

  test "should strip different template roots" do
    with_template_root(["templates", "templates_mobile"]) do
      t = Ember::Handlebars::Template.new {}
      path = t.send(:template_path, 'templates/app/example')
      assert path == 'app/example', path

      path = t.send(:template_path, 'templates_mobile/app/example')
      assert path == 'app/example', path
    end
  end

  test "should allow partial templates_root matching" do
    with_template_root("templates") do
      t = Ember::Handlebars::Template.new {}
      path = t.send(:template_path, 'app/templates/example')
      assert_equal 'app/example', path

      path = t.send(:template_path, 'admin/templates/admin_example')
      assert_equal 'admin/admin_example', path
    end
  end

  test "template with AMD output" do
    with_amd_output do
      template_path = ::Rails.root.join('app/assets/javascripts/templates/test.js.hjs')
      template = Ember::Handlebars::Template.new template_path.to_s
      asset = app.assets.attributes_for(template_path)

      assert_match /define\('appkit\/templates\/test', \['exports'\], function\(__exports__\)\{ __exports__\['default'\] = Ember\.(?:Handlebars|HTMLBars)\.template\(/m, template.render(asset)
    end
  end

  test "asset pipeline should serve template" do
    get "/assets/templates/test.js"
    assert_response :success
    assert_match /Ember\.TEMPLATES\["test"\] = Ember\.(?:Handlebars|HTMLBars)\.template\(/m, @response.body
  end

  test "asset pipeline should serve bundled application.js" do
    get "/assets/application.js"
    assert_response :success
    assert_match /Ember\.TEMPLATES\["test"\] = Ember\.(?:Handlebars|HTMLBars)\.template\(/m, @response.body
  end

  test "should unbind mustache templates" do
    get "/assets/templates/hairy.mustache"
    assert_response :success
    assert_match /Ember\.TEMPLATES\["hairy(\.mustache)?"\] = Ember\.(?:Handlebars|HTMLBars)\.template\(/m, @response.body
    assert_match /function .*unbound|"name":"unbound"/m, @response.body
  end

  test "ensure new lines inside the anon function are persisted" do
    get "/assets/templates/new_lines.js"
    assert_response :success
    assert @response.body =~ /; data = data || {};\n|"data":data/, @response.body.inspect
  end

  test "compile template with Handlebars namespace" do
    with_ember_template 'Handlebars' do
      template_path = ::Rails.root.join('app/assets/javascripts/templates/test.js.hjs')
      template = Ember::Handlebars::Template.new template_path.to_s
      asset = app.assets.attributes_for(template_path)

      assert_match /Ember\.TEMPLATES\["test(\.js)?"\] = Ember\.Handlebars\.template\(/m, template.render(asset)
    end
  end

  test "compile template with HTMLBars namespace" do
    with_ember_template 'HTMLBars' do
      template_path = ::Rails.root.join('app/assets/javascripts/templates/test.js.hjs')
      template = Ember::Handlebars::Template.new template_path.to_s
      asset = app.assets.attributes_for(template_path)

      assert_match /Ember\.TEMPLATES\["test(\.js)?"\] = Ember\.HTMLBars\.template\(/m, template.render(asset)
    end
  end

end
