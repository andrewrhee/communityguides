require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  # create
  test "should not create comment anonymous" do
    assert_no_difference('Comment.count', 'Comment count has changed but should not') do
      post :create, :article_id => articles(:seven).id, :comment => { :user_id => users(:user2).id, :body => 'Comment' }
    end
    assert_redirected_to new_user_session_path
  end  
  test "should create comment signed in" do
    sign_in users(:user2)
    assert_difference('Comment.count', 1, 'Comment count has not changed') do
      post :create, :article_id => articles(:seven).id, :comment => { :user_id => users(:user2).id, :body => 'Comment' }
    end
    assert_redirected_to article_path(assigns(:article))
    assert_equal 'Comment was successfully created.', flash[:notice]
  end
  test "should not create comment not assigned to article" do
    sign_in users(:user2)
    assert_raises(ActiveRecord::RecordNotFound) do
      assert_no_difference('Comment.count', "Comment count has changed but should not") do
        post :create, :article_id => 100, :comment => { :user_id => users(:user2).id, :body => 'Comment' }
      end  
    end
  end
  test "should not create comment not assigned to other user" do
    sign_in users(:user2)
    assert_difference('Comment.count', 1, 'Comment count has not changed') do
      post :create, :article_id => articles(:seven).id, :comment => { :user_id => users(:user1).id, :body => 'Comment' }
    end
    assert assigns(:comment).user_id == users(:user2).id, "Comment does not belong to the current user"   
  end    
  test "should not assign comment to other article" do
    sign_in users(:user2)
    assert_difference('Comment.count', 1, 'Comment count has not changed') do
      post :create, :article_id => articles(:seven).id, :comment => { :article_id => articles(:six).id, :user_id => users(:user2).id, :body => 'Comment' }
    end
    assert_redirected_to article_path(assigns(:article))
    assert_equal 'Comment was successfully created.', flash[:notice]
    assert assigns(:comment).article_id ==  articles(:seven).id, "Comment does not belong to the right article"   
  end

  test "should create comment for published articles only" do
    sign_in users(:user2)
    assert_no_difference('Comment.count', 'Comment count has changed but should not') do
      post :create, :article_id => articles(:three).id, :comment => { :user_id => users(:user2).id, :body => 'Comment' }
    end
    assert_no_difference('Comment.count', 'Comment count has changed but should not') do
      post :create, :article_id => articles(:four).id, :comment => { :user_id => users(:user2).id, :body => 'Comment' }
    end
    assert_no_difference('Comment.count', 'Comment count has changed but should not') do
      post :create, :article_id => articles(:five).id, :comment => { :user_id => users(:user2).id, :body => 'Comment' }
    end    
    assert_difference('Comment.count', 1, 'Comment count has not changed') do
      post :create, :article_id => articles(:six).id, :comment => { :user_id => users(:user2).id, :body => 'Comment' }
    end    
    assert_difference('Comment.count', 1, 'Comment count has not changed') do
      post :create, :article_id => articles(:seven).id, :comment => { :user_id => users(:user2).id, :body => 'Comment' }
    end
  end
  
 # destroy
  test "should not destroy comment anonymous" do
    assert_no_difference('Comment.count') do
      delete :destroy, :article_id => comments(:three).article_id, :id => comments(:three).id
    end
    assert_redirected_to new_user_session_path
  end
  test "should destroy comment signed in" do
    sign_in users(:user2)
    assert_difference('Comment.count', -1) do
      delete :destroy, :article_id => comments(:three).article_id, :id => comments(:three).id
    end
    assert_redirected_to article_path(assigns(:article))
  end
  test "should not destroy comment linked to other user" do
    sign_in users(:user2)
    assert_raises(ActiveRecord::RecordNotFound) do
      assert_no_difference('Comment.count', "Comment count has changed but should not") do
        delete :destroy, :user_id => users(:user1).id, :article_id => comments(:one).id, :id => comments(:one).id
      end  
    end
  end  
end