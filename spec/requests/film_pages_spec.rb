require 'spec_helper'
require 'rails_helper'
require 'support/utilities'

describe "Film pages" do
  let(:film) {FactoryGirl.create(:film)}
  let(:user) {FactoryGirl.create(:user)}
  let(:tag) {FactoryGirl.create(:tag)}

  before do
    visit signin_path
    fill_in "Email",        with: user.email
    fill_in "Password",     with: "foobar"
    click_button "Sign in"
  end

  describe "Adding film to favourites" do
    before {click_button "Favourite"}

    let(:preference) {Preference.find_by_fan_id_and_favfilm_id(user.id,film.id)}

    it { expect(preference.fan).to eq user}
    it { expect(preference.favfilm).to eq film}

    describe "followed by removing from favourites" do
      before {click_button "Not favourite"}
    end
  end

  describe "Removing film from favs" do

  end

  describe "User rates film" do

  end

  describe "User changes film rating" do

  end
end