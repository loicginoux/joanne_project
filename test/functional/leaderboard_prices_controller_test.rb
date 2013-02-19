require 'test_helper'

class LeaderboardPricesControllerTest < ActionController::TestCase
  setup do
    @leaderboard_price = leaderboard_prices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:leaderboard_prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create leaderboard_price" do
    assert_difference('LeaderboardPrice.count') do
      post :create, leaderboard_price: { name: @leaderboard_price.name }
    end

    assert_redirected_to leaderboard_price_path(assigns(:leaderboard_price))
  end

  test "should show leaderboard_price" do
    get :show, id: @leaderboard_price
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @leaderboard_price
    assert_response :success
  end

  test "should update leaderboard_price" do
    put :update, id: @leaderboard_price, leaderboard_price: { name: @leaderboard_price.name }
    assert_redirected_to leaderboard_price_path(assigns(:leaderboard_price))
  end

  test "should destroy leaderboard_price" do
    assert_difference('LeaderboardPrice.count', -1) do
      delete :destroy, id: @leaderboard_price
    end

    assert_redirected_to leaderboard_prices_path
  end
end
