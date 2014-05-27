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

  describe "role should default to 0" do
    before { @user = User.new(first: "foo", last: "bar", login: "user", password: "foobar", password_confirmation: "foobar") }
    its(:role) { should == 0 }
  end

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when first is not present" do
    before { @user.first = " " }
    it { should_not be_valid }
  end

  describe "when last is not present" do
    before { @user.last = " " }
    it { should_not be_valid }
  end

  describe "when login is not present" do
    before { @user.login = " " }
    it { should_not be_valid }
  end

  describe "when login is too long" do
    before { @user.login = "a" * 19 }
    it { should_not be_valid }
  end

  describe "when login is too short" do
    before { @user.login = "a" * 2 }
    it { should_not be_valid }
  end

  describe "when login format is invalid" do
    it "should be invalid" do
      logins = %w[bar! -foo bar- foo@bar foo_bar _foo]
      logins.each do |invalid_login|
        @user.login = invalid_login
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when login format is valid" do
    it "should be valid" do
      logins = %w[9foo foo9 foo foo-bar foo9bar foo9-bar9 9foo-bar9 9foobar9]
      logins.each do |valid_login|
        @user.login = valid_login
        expect(@user).to be_valid
      end
    end
  end

  describe "when first is too long" do
    before { @user.first = "a" * 31 }
    it { should_not be_valid }
  end

  describe "when last is too long" do
    before { @user.last = "a" * 31 }
    it { should_not be_valid }
  end

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

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

end