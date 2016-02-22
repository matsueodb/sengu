# == Schema Information
#
# Table name: element_value_string_contents
#
#  id         :integer          not null, primary key
#  value      :string(255)
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

#
#== １行入力
#
class ElementValue::UploadFile < ElementValue::StringContent
  attr_accessor :upload_file, :temp
  
  after_save do
    open(path, "wb") do |w|
      IO.copy_stream self.temp, w
    end if self.temp
  end
  before_destroy do
    File.delete path if File.exist? path
  end

  #=== データセット
  def upload_file=(val)
    self.temp = val
    self.value = val.original_filename
  end

  #=== アップロードされているファイルの絶対パスを返す
  def path
    File.expand_path(File.join(Settings.files.upload_file.dir_path, id.to_s))
  end

  #=== ラベル（ファイル名）を返す
  def formatted_value
    ev = self.element_value
    label_kind = ElementValue::KINDS[:upload_file][:label]
    file_kind = ElementValue::KINDS[:upload_file][:file]
    if ev.kind == label_kind
      # selfがlabel
      file_value = ElementValue.find_by(kind: file_kind, element_id: ev.element_id, record_id: ev.record_id, item_number: ev.item_number)
      "#{self.value}(#{file_value.try(:value)})"
    else
      # selfがfile
      label_value = ElementValue.find_by(kind: label_kind, element_id: ev.element_id, record_id: ev.record_id, item_number: ev.item_number)
      "#{label_value.try(:value)}(#{self.value})"
    end
  end
end
