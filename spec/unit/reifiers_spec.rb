RSpec.describe ActiveConformity::Reifiers do

  before do
    @object = Object.new
    @object.extend(ActiveConformity::Reifiers)
    @rule = {
              "content"=>{ "presence" => true}
            }
  end

  describe "reify_rule" do
    it "should symbolize all the keys of the rule" do
      expect(@object.reify_rule(@rule)).to eq({content: { presence: true }})
    end

    it "should convert format rules to regex" do
      @rule.merge!("format" => {"with"=> /d+/})
      expect(@object.reify_rule(@rule)).to eq(
      {:content=>{:presence=>true}, :format=>{:with=>/d+/}})
    end
  end
end
