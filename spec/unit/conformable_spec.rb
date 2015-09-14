require 'spec_helper'
RSpec.describe ActiveConformity::Conformable do
  before do
    rebuild_model
    @dummy_type = DummyType.new
    @dummy_type.system_name = "need_content_dummy"
    @dummy_type.save
    @dummy = Dummy.create!(content: "hello there")
    @dummy.dummy_type = @dummy_type
    @dummy.save!
    @conformable = ActiveConformity::Conformable.new
    @conformable.conformity_set = {content: { length: {minimum: 50} } }.to_json
    @conformable.conformable_id = @dummy_type.id
    @conformable.conformable_type = @dummy_type.class.name
    @conformable.conformist_type = @dummy.class.name
    @conformable.save!
  end

  describe "adding conformity set" do
    it "should add the conformity set to the existing conformable set" do
      @conformable.add_conformity_set({title: {length: {minimum: 10}}})
      @conformable.save!
      @conformable.reload
      expect(@conformable.conformity_set).to eq(
                        {
                          content: { length: { minimum: 50 } },
                          title: { length: { minimum: 10 }  }
                        })
    end
    it "should update existing validations the conformity set to the existing conformable set" do
      @conformable.add_conformity_set({title: {length: {minimum: 100}}})
      @conformable.save!
      @conformable.reload
      expect(@conformable.conformity_set).to eq(
                        {
                          content: { length: { minimum: 50 } },
                          title: { length: { minimum: 100 }  }
                        })
    end
  end

  describe "removing a conformity set rule" do
    it "shold remove the entire conformity set rule specified by the top level key" do
      @conformable.add_conformity_set({title: {length: {minimum: 100}}})
      @conformable.save!
      @conformable.reload
      @conformable.remove_coformity_rule(:title)
      @conformable.save!
      expect(@conformable.conformity_set).to eq(
                        {
                          content: { length: { minimum: 50 } }
                        })
    end
    it "should raise an error if the top level key is not found" do
      @conformable.add_conformity_set({title: {length: {minimum: 100}}})
      @conformable.save!
      @conformable.reload
      expect{@conformable.remove_coformity_rule(:no_title)}.to raise_error("no rule found for no_title")
    end

    it "appending a bang will run a save!" do
      @conformable.add_conformity_set({title: {length: {minimum: 100}}})
      @conformable.save!
      @conformable.reload
      @conformable.remove_coformity_rule!(:title)
      @conformable.reload
      expect(@conformable.conformity_set).to eq(
                        {
                          content: { length: { minimum: 50 } }
                        })
    end
  end
end
