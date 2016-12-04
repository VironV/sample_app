require 'spec_helper'
require 'rails_helper'
require 'support/utilities'

RSpec.describe Film_factor, type: :model do

  let(:value) {-2.3}
  let(:user) {FactoryGirl.create(:user)}
  let(:factor) {FactoryGirl.create(:factor)}
  before do
    @film_factor=Film_factor.new(user_id:user.id,factor_id: factor.id, value: value)
  end

  subject { @film_factor}

  it {should be_valid}

  describe "film factor methods" do
    it {should respond_to(:user)}
    it {should respond_to(:factor)}
    it { expect(subject.film).to eq film}
    it { expect(subject.factor).to eq factor}
  end

  describe "when film id is not presented" do
    before {subject.user = nil}
    it {should_not be_valid}
  end

  describe "when factor id is not presented" do
    before {subject.factor_id=nil}
    it {should_not be_valid}
  end

  describe "when same preference already exits" do
    before do
      same_film_factor=subject.dup
      same_film_factor.save
    end

    it {should_not be_valid}
  end

end
