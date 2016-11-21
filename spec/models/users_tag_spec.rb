require 'rails_helper'

RSpec.describe Users_tag, type: :model do

  let(:user) {FactoryGirl.create(:user)}
  let(:tag) {FactoryGirl.create(:tag)}
  count=1
  #let(:films_tag) {user.films_tag.build(tag_id: tag.id)}

  before do
    @users_tag = Users_tag.new(user_id: user.id,tag_id: tag.id, count: count)
  end

  subject { @users_tag}

  it {should be_valid}

  describe "methods" do
    it {should respond_to(:user)}
    it {should respond_to(:tag)}
    it {should respond_to(:count)}
    it { expect(subject.user).to eq user}
    it { expect(subject.tag).to eq tag}
    it { expect(subject.count).to eq count}
  end

  describe "when user id is not presented" do
    before {subject.user_id=nil}
    it {should_not be_valid}
  end

  describe "when tag id is not presented" do
    before {subject.tag_id=nil}
    it {should_not be_valid}
  end

  describe "when users tags count is not presented" do
    before {subject.count=nil}
    it {should_not be_valid}
  end

  describe "when same users tag already exits" do
    before do
      same_users_tag=subject.dup
      same_users_tag.save
    end

    it {should_not be_valid}
  end
end
