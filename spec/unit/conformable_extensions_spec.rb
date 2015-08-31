require 'spec_helper'
RSpec.describe ActiveConformity::ConformableExtensions do
  before do
    rebuild_model
    @dummy_type1 = DummyType.create!(system_name: "need_content_dummy")
    @dummy_type2 = DummyType.create!(system_name: "need_title")
    @dummy1 = Dummy.create!(content: "hello there", dummy_type: @dummy_type1)
    @conformable1 = ActiveConformity::Conformable.create!(
      conformity_set:{content: { presence: true } }.to_json,
      conformable_id: @dummy_type1.id,
      conformable_type: @dummy_type1.class.name,
      conformist_type: @dummy1.class.name
    )
    @conformable2 = ActiveConformity::Conformable.create!(
      conformity_set:{content: { presence: true } }.to_json,
      conformable_id: @dummy_type2.id,
      conformable_type: @dummy_type2.class.name,
      conformist_type: @dummy1.class.name
    )
  end

  describe "checking conformity" do
    it "runs all of the related conformable validations and returns errors when the model does not conform" do
      @dummy1.content = nil
      expect(@dummy1.conforms?).to eq false
      expect(@dummy1.conformity_errors).to eq({:content =>["can't be blank"]})
    end

    it "runs all of the related conformable validations and returns true when the model conforms" do
      expect(@dummy1.conforms?).to eq true
    end
  end

  describe "#conformable_references" do
    it "returns all of the classes which define how the model conforms" do
      expect(@dummy1.conformable_references).to eq [@dummy_type1]
    end
  end
end
