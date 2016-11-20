require 'rails_helper'

RSpec.describe Preference, type: :model do

  let(:fan) {FactoryGirl.create(:user)}
  let(:favfilm) {FactoryGirl.create(:film)}
  #let(:preference) {fan.preferences.build(favfilm_id: favfilm.id)}
  before do
    @preference = Preference.new(fan_id: fan.id,favfilm_id: favfilm.id)
  end

  subject { @preference}

  it {should be_valid}

  describe "fan methods" do
    it {should respond_to(:fan)}
    it {should respond_to(:favfilm)}
    it { expect(subject.fan).to eq fan}
    it { expect(subject.favfilm).to eq favfilm}
  end

  describe "when fan id is not presented" do
    before {subject.fan = nil}
    it {should_not be_valid}
  end

  describe "when favfilm id is not presented" do
    before {@preference.favfilm_id=nil}
    it {should_not be_valid}
  end
end
