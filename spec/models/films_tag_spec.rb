require 'rails_helper'

RSpec.describe Films_tag, type: :model do

  let(:film) {FactoryGirl.create(:film)}
  let(:tag) {FactoryGirl.create(:tag)}
  #let(:films_tag) {user.films_tag.build(tag_id: tag.id)}

  before do
    @films_tag = Films_tag.new(film_id: film.id,tag_id: tag.id)
  end

  subject { @films_tag}

  it {should be_valid}

  describe "methods" do
    it {should respond_to(:film)}
    it {should respond_to(:tag)}
    it { expect(subject.film).to eq film}
    it { expect(subject.tag).to eq tag}
  end

  describe "when film id is not presented" do
    before {subject.film_id=nil}
    it {should_not be_valid}
  end

  describe "when tag id is not presented" do
    before {subject.tag_id=nil}
    it {should_not be_valid}
  end
end
