require 'test_helper'

class IssuesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get issues_new_url
    assert_response :success
  end

  test "should get create" do
    get issues_create_url
    assert_response :success
  end

  test "should get index" do
    get issues_index_url
    assert_response :success
  end

  test "should get show" do
    get issues_show_url
    assert_response :success
  end

  test "should get edit" do
    get issues_edit_url
    assert_response :success
  end

  test "should get update" do
    get issues_update_url
    assert_response :success
  end

  test "should get destroy" do
    get issues_destroy_url
    assert_response :success
  end

  test "should get choice" do
    get issues_choice_url
    assert_response :success
  end

  test "should get confirm" do
    get issues_confirm_url
    assert_response :success
  end

  test "should get update_status" do
    get issues_update_status_url
    assert_response :success
  end

end
