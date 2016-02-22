shared_examples "Concerns::ElementValueVocabulary#formatted_valueの検証" do
  it "self.valueがnilの場合、nilが返ること" do
    content.stub(:value){nil}
    expect(subject).to be_nil
  end

  it "self.valueがnil以外の場合、参照先のデータの値が返ること" do
    val = "松江城"
    ve = create(:vocabulary_element)
    vev = create(:vocabulary_element_value, name: val)
    content_element = create(:element_by_it_checkbox_vocabulary, source: ve)
    ev = create(:element_value, content: content, element_id: content_element.id)
    content.update(value: vev.id)
    expect(subject).to eq(val)
  end
end
