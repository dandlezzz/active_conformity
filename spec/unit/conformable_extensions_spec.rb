  require 'spec_helper'
  RSpec.describe ActiveConformity::ConformableExtensions do
    before do
      rebuild_model
      @dummy_type1 = DummyType.create!(system_name: "need_content_dummy")
      @dummy_type2 = DummyType.create!(system_name: "need_title")
      @dummy1 = Dummy.create!(content: "hello there", dummy_type: @dummy_type1)
      @option = Option.create!
      @dummy_option = DummyOption.create(value: nil,
                      dummy_id: @dummy1.id, option_id: @option.id)
      @conformable3 = ActiveConformity::Conformable.create!(
        conformity_set:{value: { presence: true } }.to_json,
        conformable_id: @option.id,
        conformable_type: @option.class.name,
        conformist_type:  @dummy_option.class.name
      )
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

      it "returns all of the classes which define how the model conforms and doesn't disregard self conformity" do
        @conformable1 = ActiveConformity::Conformable.create!(
          conformity_set:{content: { presence: true } }.to_json,
          conformable_id: @dummy1.id,
          conformable_type: @dummy1.class.name,
          conformist_type: @dummy1.class.name
        )
        expect(@dummy1.conformable_references).to eql([@dummy_type1,  @dummy1])
      end
    end

    describe "conformity_set" do
      it "when called on a conformable references gets the conformables conformity set" do
        expect(@dummy_type1.conformity_set).to eq({content: { presence: true } })
      end
    end

    describe "#conformable" do
      it "returns the conformable_reference for the conformable" do
        expect(@dummy_type1.conformable).to eq(@conformable1)
      end
    end

    describe "adding a conformity set" do
      it "add a conformity set to a conformable" do
        ActiveConformity::Conformable.where(conformable_id: @dummy_type1.id).delete_all
        @dummy_type1.add_conformity_set!({title: { length: {minimum: 0, maximum: 10} } }.to_json, @dummy1.class.name)
        @dummy_type1.reload
        expect(@dummy_type1.conformable.conformity_set).to eq({title: { length: {minimum: 0, maximum: 10} } })
      end
    end

    describe "removing a conformity set" do
      it "removes a conformity rule and runs a save" do
        ActiveConformity::Conformable.where(conformable_id: @dummy_type1.id).delete_all
        @dummy_type1.add_conformity_set!({title: { length: {minimum: 0, maximum: 10} } }.to_json, @dummy1.class.name)
        @dummy_type1.reload
        @dummy_type1.remove_conformity_rule!(:title)
        expect(@dummy_type1.conformable.conformity_set).to eq({})
        expect(@dummy1.reload.aggregate_conformity_set).to eq({})
      end

      it "removes a all conformity rules and runs a save" do
        ActiveConformity::Conformable.where(conformable_id: @dummy_type1.id).delete_all
        @dummy_type1.add_conformity_set!({title: { length: {minimum: 0, maximum: 10} } }.to_json, @dummy1.class.name)
        @dummy_type1.reload
        @dummy_type1.remove_rules
        expect(@dummy_type1.conformable.conformity_set).to eq({})
        expect(@dummy1.reload.aggregate_conformity_set).to eq({})
      end
    end

    describe "conforming dependents" do
      it "allows the conformable class to specify its conforming dependents" do
        @dummy1.class.conforming_dependents(:dummy_options)
        expect(@dummy1.class.dependents).to eq ([:dummy_options])
      end

      it "checks the dependents for conformity and returns true when they do conform"do
        @dummy1.class.conforming_dependents(:dummy_options)
        DummyOption.first.update(value: "Nice Value")
        expect(@dummy1.conforms?).to be true
      end

      it "checks the dependents for conformity and returns false when they dont conform"do
        @dummy1.class.conforming_dependents(:dummy_options)
        expect(@dummy1.conforms?).to be false
      end

      it "should raise an error if a relation is not passed into conforming dependents"do
        expect {@dummy1.class.conforming_dependents(:dummy_optionals)}.to raise_error
      end

      ## NEED a smart way to display errors from the conforming dependents
    end
  end
