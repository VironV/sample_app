require 'spec_helper'
require 'rails_helper'
require 'support/utilities'

describe "Static pages" do

  let(:base_title) { "Ruby on Rails Tutorial Sample App" }
  let(:film) {FactoryGirl.create(:film)}
  let(:user) {FactoryGirl.create(:user)}

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    describe "when not sined in" do
      before { visit root_path }
      let(:heading) {'Sample App'}
      let(:page_title) {''}

      it_should_behave_like "all static pages"
      it { should_not have_title('| Home') }
    end

    describe "when signed in" do
      before do
        visit signin_path
        fill_in "Email",        with: user.email
        fill_in "Password",     with: "foobar"
        click_button "Sign in"
      end
      it "shoud redirect to user page" do
        expect(page).to have_title(full_title(user.name))
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading) {'Help'}
    let(:page_title) {'Help'}
    it_should_behave_like "all static pages"

  end

  describe "Films list page" do
    before {visit films_list_path}

  end

  describe "About page" do
    before { visit about_path }
    let(:heading) {'About Us'}
    let(:page_title) {'About'}
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading) {'Contact'}
    let(:page_title) {'Contact'}
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Films"
    expect(page).to have_title(full_title('Films list'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    expect(page).to have_title(full_title(''))
    expect(page).to_not have_title(full_title('Home'))
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign up'))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
    expect(page).to_not have_title(full_title('Home'))
  end
end