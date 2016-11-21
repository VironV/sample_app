require 'rails_helper'

RSpec.describe Film, type: :model do

  before do
    @film = Film.new(title: "Matrix", director: "Some random name",year: "1951")
  end

  subject { @film }

  it { should respond_to(:title) }
  it { should respond_to(:director) }
  it { should respond_to (:year) }

  it {should respond_to(:preferences)}

  it { should be_valid }

  describe "when title is not present" do
    before {@film.title= " "}
    it {should_not be_valid}
  end

  describe "when director is not present" do
    before {@film.director= " "}
    it {should_not be_valid}
  end

  describe "when year is not present" do
    before {@film.year= " "}
    it {should_not be_valid}
  end

  describe "when same film already exits" do
    before do
      same_film=@film.dup
      same_film.save
    end

    it {should_not be_valid}
  end

end
