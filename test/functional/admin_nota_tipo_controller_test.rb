require 'test_helper'

class Admin::NotaTiposControllerTest < ActionController::TestCase

  setup do
    @nota_tipo = nota_tipos(:ao)
    login_as :admin
  end

  test "should show index" do
    get :index
    assert_response :success
  end

  test "should show detalles" do
    get :show, id: @nota_tipo
    assert_response :success
  end

  test "should show new" do
    get :new
    assert_response :success
  end

  test "should show edit" do
    get :edit, id: @nota_tipo
    assert_response :success
  end

end