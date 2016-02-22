# == Schema Information
#
# Table name: template_records
#
#  id          :integer          not null, primary key
#  template_id :integer
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :template_record do
    template_id 1
    user_id 1

    factory :tr_with_all_values do
      before(:create) do |tr|
        InputType::TYPE_HUMAN_NAME.each do |name, label|
          it = InputType.find_by(name: name)
          el = Element.find_by(template_id: tr.template_id, input_type_id: it.id) if it
          case name
          when "all_locations"
            el ||= create("element_by_it_#{name}".to_sym)
            ElementValue::KINDS[name.to_sym].each do |type, va|
              vals = va.values
              [:lat, :lon].zip(vals).map do |key, kind|
                evc = create(:"element_value_#{name}_#{type}_#{key}")
                tr.values << create(:element_value, content: evc, element_id: el.id, kind: kind)
              end
            end
          when "kokudo_location", "google_location", "osm_location"
            el ||= create("element_by_it_#{name}".to_sym)
            vals = ElementValue::KINDS[name.to_sym].values
            [:lat, :lon].zip(vals).map do |key, kind|
              evc = create(:"element_value_#{name}_#{key}")
              tr.values << create(:element_value, content: evc, element_id: el.id, kind: kind)
            end
          when "pulldown_template", "checkbox_template"
            if el.blank?
              temp = create(:template)
              el = create("element_by_it_#{name}".to_sym, source: temp)
            else
              temp = el.source
            end
            source_element = create(:element_by_it_line, template_id: temp.id)
            el.source_element_id = source_element.id

            tr1 = create(:template_record, template_id: temp.id)

            if name == "pulldown_template"
              evc = create(:"element_value_#{name}", value: tr1.id)
              tr.values << create(:element_value, content: evc, element_id: el.id, template_id: tr.template_id)
            else
              tr2 = create(:template_record, template_id: temp.id)
              [tr1, tr2].map do |rec|
                evc = create(:"element_value_#{name}", value: rec.id)
                tr.values << create(:element_value, content: evc, element_id: el.id, kind: rec.id, template_id: tr.template_id)
              end
            end
          when "pulldown_vocabulary", "checkbox_vocabulary"
            if el.blank?
              ve = create(:vocabulary_element)
              el = create("element_by_it_#{name}".to_sym, source: ve)
            else
              ve = el.source
            end

            vev = create(:vocabulary_element_value, element_id: ve.id)

            if name == "pulldown_vocabulary"
              evc = create(:"element_value_#{name}", value: vev.id)
              tr.values << create(:element_value, content: evc, element_id: el.id)
            else
              vev2 = create(:vocabulary_element_value, element_id: ve.id)
              [vev, vev2].map do |rec|
                evc = create(:"element_value_#{name}", value: rec.id)
                tr.values << create(:element_value, content: evc, element_id: el.id, kind: rec.id)
              end
            end
          when "upload_file"
            el ||= create("element_by_it_#{name}".to_sym)

            label_c = create(:element_value_upload_file, value: "テスト画像")
            tr.values << create(:element_value, content: label_c, element_id: el.id, kind: ElementValue::LABEL_KIND)
            file = ActionDispatch::Http::UploadedFile.new({:tempfile => File.new(Rails.root.join('spec', 'files', 'test.txt'))})
            file_c = create(:element_value_upload_file, value: "test.txt")
            file_c.temp = file
            tr.values << create(:element_value, content: file_c, element_id: el.id, kind: ElementValue::FILE_KIND)
          else
            el ||= create("element_by_it_#{name}".to_sym)
            evc = create(:"element_value_#{name}")
            tr.values << create(:element_value, content: evc, element_id: el.id)
          end
          tr.template.elements << el if el
        end
      end
    end

    factory :template_records_with_values do
      after(:create) do |t_r|
        template = t_r.template
        template.inputable_elements.each do |element|
          input_type = element.input_type
          if input_type.location?
            contents = ['lon', 'lat'].map{|l_t| create("element_value_#{element.input_type.name}_#{l_t}")}
          else
            contents = [create("element_value_#{element.input_type.name}")]
          end
          contents.each do |content|
            create(:element_value,
                   template_id: template.id,
                   record_id: t_r.id,
                   element_id: element.id,
                   content_type: input_type.content_class_name.constantize.superclass.to_s,
                   content_id: content.id
                  )
          end
        end
      end
    end

  end
end
