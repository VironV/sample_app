require 'spec_helper'
require 'rails_helper'
require 'support/utilities'

RSpec.describe Factor, type: :model do

  before do
    @factor=Factor.new(name: "factor 2")
  end

  subject { @factor}

  it {should be_valid}

  describe "factor methods" do
    it {should respond_to(:name)}
  end

end
