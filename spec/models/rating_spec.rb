require 'rails_helper'

RSpec.describe Rating, type: :model do

  let(:film) {FactoryGirl.create(:film)}
  let(:user) {FactoryGirl.create(:user)}
  value=8
  #let(:films_tag) {user.films_tag.build(tag_id: tag.id)}

  before do
    @rating = Rating.new(film_id: film.id,user_id: user.id, value: value)
  end

  subject { @rating}

  it {should be_valid}

  describe "methods" do
    it {should respond_to(:film)}
    it {should respond_to(:user)}
    it {should respond_to(:value)}
    it { expect(subject.film).to eq film}
    it { expect(subject.user).to eq user}
    it { expect(subject.value).to eq value}
  end

  describe "when film id is not presented" do
    before {subject.film_id=nil}
    it {should_not be_valid}
  end

  describe "when user id is not presented" do
    before {subject.user_id=nil}
    it {should_not be_valid}
  end

  describe "when value" do
    describe "is not presented" do
      before {subject.value=nil}
      it {should_not be_valid}
    end

    describe "is <1" do
      before {subject.value=0}
      it {should_not be_valid}
    end

    describe "is <10" do
      before {subject.value=11}
      it {should_not be_valid}
    end
  end
end
