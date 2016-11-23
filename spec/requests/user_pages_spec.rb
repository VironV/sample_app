require 'spec_helper'
require 'rails_helper'

describe "User pages" do

  let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  subject { page }

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }


  end

  describe "favourite films list" do
    let(:film1) {FactoryGirl.create(:film)}
    let(:film2) {FactoryGirl.create(:film)}
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    describe "empty" do
      it {expect(page).to have_content("Favourite films")}
      it {expect(page).to have_content("No films in the list yet")}
    end

    describe "with some films" do
      before do
        pref1=Preference.new()
        pref1.fan_id=user.id
        pref1.favfilm_id=film1.id

        pref2=Preference.new()
        pref2.fan_id=user.id
        pref2.favfilm_id=film2.id

        pref1.save()
        pref2.save()

        visit user_path(user)
      end

      it {expect(page).to have_content(film1.title)}
      it {expect(page).to have_content(film2.title)}
    end
  end

  describe "signup page" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
      end

      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit edit_user_path(user) }

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    #describe "with invalid information" do
    #  before { click_button "Save changes" }

      #it { should have_selector('div.alert.alert-error', text: 'Error') }
    #end
  end
end