require 'spec_helper'
RSpec.describe ConformitySetValidator do
  before do
    rebuild_model
    @dummy_type = DummyType.new
    @dummy_type.system_name = "need_content_dummy"
    @dummy_type.save
    @dummy = Dummy.create!(content: "hello there")
    @dummy.dummy_type = @dummy_type
    @dummy.save
    @conformable = ActiveConformity::Conformable.new
    @conformable.conformity_set = {content: { presence: true } }.to_json
    @conformable.conformable_id = @dummy_type.id
    @conformable.conformable_type = @dummy_type.class.name
    @conformable.conformist_type = @dummy.class.name
    @conformable.save
    module ActiveConformityCustomMethods
      def dummy_custom
        return true
      end
    end
  end

  it "should be a ActiveModel Validator" do
    expect(ConformitySetValidator.superclass).to eq ActiveModel::EachValidator
  end

  it "should not be valid if no conformity set is passed in" do
    @conformable.conformity_set = nil
    expect(@conformable.valid?).to be false
  end

  it "should validate the conformables conformity set when valid" do
    expect(@conformable).to be_valid
  end

  it "should invalidate the conformables conformity set the attribute key is not an attribute of the conformable" do
    @conformable.conformity_set = {name: { presence: true } }.to_json
    @conformable.save
    expect(@conformable).to be_invalid
  end

  it "should require the conformity set to be a hash" do
    @conformable.conformity_set = "not a hash"
    @conformable.save
    expect(@conformable).to be_invalid
  end

  it "should invalidate the conformables conformity set the attribute key is not a valid rails attribute" do
    @conformable.conformity_set = {content: { good: true } }.to_json
    @conformable.save
    expect(@conformable).to be_invalid
  end

  it "should permit the use of regex validations" do
    @conformable.conformity_set =  {content: {format: {with: /\d+/} } }.to_json
    @conformable.save
    expect(@conformable).to be_valid
  end

  it "should permit the use of length validations" do
    @conformable.conformity_set =  {content: {length: { minimum: 4}}}.to_json
    @conformable.save
    expect(@conformable).to be_valid
  end

  it "should permit the use of numericality validations" do
    @conformable.conformity_set =  {content: {numericality: { greater_than_or_equal_to: 1}}}.to_json
    @conformable.save
    expect(@conformable).to be_valid
  end

  # it "should not allow custom methods that aren't already defined" do
  #   @conformable.conformity_set = {method: "not_dummy_custom" }.to_json
  #   @conformable.save
  #   expect(@conformable).to be_invalid
  # end

  # it "should correctly populate the errors for bad validation sets" do
  #   @conformable.conformity_set = {method: "not_dummy_custom" }.to_json
  #   @conformable.save
  #   expect(@conformable.errors.messages).to eq({:conformity_set=>["not_dummy_custom is not defined in ActiveConformityCustomMethods!"]})
  # end

  it "should allow predefined custom methods" do
    @conformable.conformity_set = {method: "dummy_custom" }.to_json
    @conformable.save
    expect(@conformable).to be_valid
  end
end
