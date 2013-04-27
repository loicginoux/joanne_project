require 'spec_helper'

def valid_attr(user)
  {
  "sender" => user.email,
  "attachment-1" => fixture_file_upload('/images/test1.png', 'image/png'),
  "Subject" => "123",
  "stripped-text" => "description test"
  }
end

def invalid_attr(user)
  {
  "sender" => user.email,
  "Subject" => "",
  "stripped-text" => ""
  }
end

def attr_with_no_user()
  {
  "sender" => "wrong@test.com",
  "Subject" => "123",
  "attachment-1" => fixture_file_upload('/images/test1.png', 'image/png'),
  "stripped-text" => ""
  }
end

describe DataPointsController do
  describe "POST #create" do
    context "sending an email" do
      before do
        @user = FactoryGirl.create(:user)
      end
      context "with correct email" do
        before do
          post :create, valid_attr(@user)
        end

        it "create the photo" do
          expect{
              post :create, valid_attr(@user)
            }.to change(DataPoint,:count).by(1)
        end

        it { should respond_with(200) }
      end

      context "with no attachement" do
        before do
          post :create, invalid_attr(@user)
        end

        it { should respond_with(200) }
      end

      context "with email not in database" do
        before do
          post :create, attr_with_no_user()
        end
        it { should respond_with(200) }
      end
    end
  end
end