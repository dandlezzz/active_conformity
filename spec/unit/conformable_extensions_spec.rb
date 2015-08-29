require 'spec_helper'
RSpec.describe ActiveConformity::ConformableExtensions do
  before do
    rebuild_model
    @dummy_type = DummyType.new
    @dummy_type.system_name = "need_content_dummy"
    @dummy_type.save
    @dummy = Dummy.create!(content: "hello there")
    @dummy.dummy_type = @dummy_type
    @dummy.save!
    @conformable = ActiveConformity::Conformable.new
    @conformable.conformity_set = {content: { presence: true } }.to_json
    @conformable.conformable_id = @dummy_type.id
    @conformable.conformable_type = @dummy_type.class.name
    @conformable.conformist_type = @dummy.class.name
    @conformable.save!
  end

  describe "checking conformity" do
    it "runs all of the related conformable validations and returns errors when the model does not conform" do
      @dummy.content = nil
      expect(@dummy.conforms?).to eq false
      expect(@dummy.conformity_errors).to eq({:content =>["can't be blank"]})
    end

    it "runs all of the related conformable validations and returns true when the bool conforms" do
      expect(@dummy.conforms?).to eq true
    end
  end

  describe "#conformable_references" do
    it "runs all of the related objects with conformable references" do
      expect(@dummy.conformable_references).to eq [@dummy_type]
    end
  end

end
