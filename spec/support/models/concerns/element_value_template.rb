shared_examples "Concerns::ElementValueTemplate#formatted_valueの検証" do
  it "self.valueがnilの場合、nilが返ること" do
    content.stub(:value){nil}
    expect(subject).to be_nil
  end

  it "self.valueがnil以外の場合、参照先のデータの値が返ること" do
    val = "松江城"
    c = create(:element_value_line, value: val)
    temp = create(:template)
    el = create(:"element_by_it_line", template_id: temp.id)
    tr = create(:template_record, template_id: temp.id)
    create(:element_value, content: c, element_id: el.id, record_id: tr.id)

    content_element = create(:element_by_it_checkbox_template, source: temp, source_element_id: el.id)
    ev = create(:element_value, content: content, element_id: content_element.id)
    content.update(value: tr.id)
    expect(subject).to eq(val)
  end
end
