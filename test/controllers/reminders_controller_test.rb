require "test_helper"

class RemindersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reminders_index_url
    assert_response :success
  end

  test "should get new" do
    get reminders_new_url
    assert_response :success
  end

  test "should get create" do
    get reminders_create_url
    assert_response :success
  end

  test "should get edit" do
    get reminders_edit_url
    assert_response :success
  end

  test "should get update" do
    get reminders_update_url
    assert_response :success
  end

  test "should get destroy" do
    get reminders_destroy_url
    assert_response :success
  end
end
