require 'spec_helper'
require 'rails_helper'
require 'support/utilities'

describe "Film pages" do
  let(:film) {FactoryGirl.create(:film)}
  let(:user) {FactoryGirl.create(:user)}
  let(:tag) {FactoryGirl.create(:tag)}

  subject {page}

  before do
    visit signin_path
    fill_in "Email",        with: user.email
    fill_in "Password",     with: "foobar"
    click_button "Sign in"
    visit film_path(film.id)
  end

  describe "adding film to favourites" do
    before {click_button "Make this film favourite"}

    let(:preference) {Preference.find_by_fan_id_and_favfilm_id(user.id,film.id)}

    it { expect(preference.fan_id).to eq user.id}
    it { expect(preference.favfilm_id).to eq film.id}
    it { should have_selector('div.alert.alert-success') }
    it {should have_selector("input[type=submit][value='Remove from favourites']") }

    describe "followed by removing from favourites" do
      before {click_button "Remove from favourites"}

      let(:preference_old) {Preference.find_by_fan_id_and_favfilm_id(user.id,film.id)}

      it {expect(preference_old).to be_nil}
      it {should have_selector("input[type=submit][value='Make this film favourite']")}
      it { should have_selector('div.alert.alert-success') }
    end
  end



  describe "user rates film" do
    it {expect(page).to have_content("You didn't rate this film yet")}

    describe "Correctly" do
      before do
        select '8', from: "rating_value"
        click_button "Rate this film"
      end
      let(:rating) { Rating.find_by_film_id_and_user_id(film.id,user.id) }
      it { should have_selector('div.alert.alert-success') }
      it {expect(rating.value).to eq(8)}
      it {expect(page).to have_content("Your rating: 8")}
    end

    describe "with wrong value" do
      before do
        select '--', from: "rating_value"
        click_button "Rate this film"
      end
      let(:rating) { Rating.find_by_film_id_and_user_id(film.id,user.id) }
      it {expect(rating).to be_nil}
      it { should have_selector('div.alert.alert-error') }
    end

    describe "twice or more" do
      before do
        select '8', from: "rating_value"
        click_button "Rate this film"
        select '9', from: "rating_value"
        click_button "Rate this film"
      end
      let(:rating) { Rating.find_by_film_id_and_user_id(film.id,user.id) }
      it { should have_selector('div.alert.alert-success') }
      it {expect(rating.value).to eq(9)}
    end
  end

  describe "average rating" do
    describe "without any ratings" do
      it {expect(page).to have_content("This film hasn't any ratings yet")}
    end

    describe "with one rating" do
      before do
        select '8', from: "rating_value"
        click_button "Rate this film"
      end
      it {expect(page).to have_content("Average rating: 8")}
    end

    describe "with two or more ratings" do
      let(:user2) {FactoryGirl.create(:user)}
      before do
        select '8', from: "rating_value"
        click_button "Rate this film"

        rating2=Rating.new()
        rating2.user_id=user2.id
        rating2.film_id=film.id
        rating2.value=7
        rating2.save
        visit film_path(film.id)
      end
      it {expect(page).to have_content("Average rating: 7.5")}
    end
  end
end