require 'spec_helper'

describe User do

  before { @user = User.new(first: "Example", last: "User", login: "user", 
    email: "user@example.com", role: 1, password: "foobar", password_confirmation: "foobar") }

  subject { @user }

  it { should respond_to(:first) }
  it { should respond_to(:last) }
  it { should respond_to(:email) }
  it { should respond_to(:login) }
  it { should respond_to(:role) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  describe "when password is not present" do
    before do
      @user = User.new(first: "Example", last: "User", login: "user", 
    email: "user@example.com", role: 1, password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

end