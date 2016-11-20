require 'rails_helper'

RSpec.describe Tag, type: :model do

  let(:tag) {FactoryGirl.create(:tag)}
  #before do
  #  @tag = Tag.new(title: "Comedy", description: "It's funny")
  #end

  subject { tag }

  it { should respond_to(:title) }
  it { should respond_to(:description) }

  it { should be_valid }

  describe "when title is not present" do
    before {tag.title= " "}
    it {should_not be_valid}
  end

end