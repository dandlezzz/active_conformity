require 'spec_helper'
RSpec.describe ActiveConformity::ObjectValidator do

  before do
    rebuild_model
    @obj = Dummy.create!(title:"DumbDumb", views: 2, content: "hello")
    @conformity_set =  {content: { presence: true }}
    @object_validator = ActiveConformity::ObjectValidator.new(@obj,@conformity_set)
    module ActiveConformityCustomMethods
      def content_all_caps?
        if obj.content == obj.content.upcase
          return true
        else
          errors.add(:content, "is not all caps")
        end
      end

      def content_is?
        if obj.content == method_args[:string]
          return true
        else
          errors.add(:content, "does not match #{method_args[:string]}")
        end
      end
    end
  end

  describe "#initialize" do

    it "should set the obj" do
      expect(@object_validator.obj).to eq(@obj)
    end

    it "should set the conformity_set" do
      expect(@object_validator.conformity_set).to eq(HashWithIndifferentAccess.new(@conformity_set))
    end
  end

  describe "#create_validator_klass" do
    it "should create an instance of dynamic validator" do
      expect(@object_validator.validator_klass.superclass).to eq(ActiveConformity::DynamicValidator)
    end
  end

  describe "#check_conformity" do
    it "check to make sure the object conforms to the conformity set" do
      @obj.content = "Not So dumb!"
      expect(@object_validator.conforms?).to be true
    end

    it "specifies errors when an object does not conform" do
      @obj.content = nil
      expect(@object_validator.errors.messages).to eq({content: ["can't be blank"]})
    end

    it "provides support for numericality validations" do
      @object_validator.conformity_set[:views] = { numericality: { greater_than_or_equal_to: 1} }
      expect(@object_validator.conforms?).to be true
    end

    it "provides support for length validations" do
      @object_validator.conformity_set[:content] = { length: { minimum: 4}}
      expect(@object_validator.conforms?).to be true
    end

    it "provides support for length validations" do
      @object_validator.conformity_set[:content] = { length: { minimum: 99} }
      expect(@object_validator.conforms?).to be false
    end

    it "provides support for regex validations on failure" do
      @obj.content = "hi there"
      @object_validator.conformity_set = {content: {format: {with: /\d+/} } }
      expect(@object_validator.conforms?).to be false
    end

    it "provides support for regex validations on success" do
      @obj.content = "emergency 911"
      @object_validator.conformity_set = {content: {format: {with: /\d+/} } }
      expect(@object_validator.conforms?).to be true
    end

    # it "should raise an error for regex timeouts" do
    #   bad_regex = "(?-mix:^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$)"
    #   @obj.content = "https://sub.app.com/users/id123?hello=world"
    #   @obj.save!
    #   @object_validator.conformity_set = {content: {format: {with: bad_regex} } }
    #   expect{@object_validator.conforms?}.to raise_error
    # end

    it "supports custom validation methods on success" do
      @object_validator.conformity_set = {method: "content_all_caps?"}
      @obj.content = "THIS IS GOOD"
      expect(@object_validator.conforms?).to be true
    end

    it "supports custom validation method with arguments on success" do
      @object_validator.conformity_set = {method: {name: "content_is?", arguments: { string: "THIS IS GOOD"} } }
      @obj.content = "THIS IS GOOD"
      expect(@object_validator.conforms?).to be true
    end

    it "supports custom validation method with arguments on failure" do
      @object_validator.conformity_set = {method: {name: "content_is?", arguments: { string: "THIS ISNT GOOD"} } }
      @obj.content = "THIS IS GOOD"
      expect(@object_validator.conforms?).to be false
    end

    it "supports custom validation methods on failure" do
      @object_validator.conformity_set = {method: "content_all_caps?"}
      @obj.content = "THIS IS not GOOD"
      expect(@object_validator.conforms?).to be false
    end
  end
end
