shared_examples "Concerns::ElementValueContent#formatted_valueの検証" do
  let(:val){"松江城"}

  before do
    described_class.any_instance.stub(:value){val}
  end

  it {expect(subject).to eq(val)}
end

shared_examples "Concerns::ElementValueContent#greater_than?の検証" do
  it {expect(subject).to be_false}
end

shared_examples "Concerns::ElementValueContent#less_than?の検証" do
  it {expect(subject).to be_false}
end
