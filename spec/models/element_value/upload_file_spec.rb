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

require 'spec_helper'

describe ElementValue::UploadFile do
  let(:file) {ActionDispatch::Http::UploadedFile.new({:tempfile => File.new(Rails.root.join('spec', 'files', 'test.txt'))})}
  let(:content){create(:element_value_upload_file, value: "")}

  describe "callbacks" do
    describe "after_save" do
      let(:path){File.join(Settings.files.upload_file.dir_path, content.id.to_s)}
      before do
        content.stub(:temp){file}
      end

      subject{content.update!(value: file.original_filename)}
      
      it "self.tempの情報からファイルが作成されること" do
        File.delete path if File.exist? path
        expect{subject}.to change{File.exists?(path)}.from(false).to(true)
      end

      it "作成されたファイルがself.tempの情報と等しいこと" do
        file_read = File.read(Rails.root.join('spec', 'files', 'test.txt'))
        subject
        expect(file_read).to eq(File.read(path))
      end

      after do
        File.delete path if File.exist? path
      end
      
    end

    describe "before_destroy" do
      let(:path){File.join(Settings.files.upload_file.dir_path, content.id.to_s)}

      before do
        File.open(path, "w").close()
      end

      it "アップロードされていたファイルが削除されること" do
        expect{content.destroy}.to change{File.exists?(path)}.from(true).to(false)
      end

      after do
        # 念のため
        File.delete path if File.exist? path
      end
    end
  end

  describe "methods" do
    describe "#upload_file=" do
      subject{content.upload_file = file}

      it "self.tempに引数で渡した値がセットされること" do
        expect{subject}.to change{content.temp}.from(nil).to(file)
      end

      it "self.valueに引数で渡した値のoriginal_filenameがセットされること" do
        filename = file.original_filename
        expect{subject}.to change{content.value}.from("").to(filename)
      end
    end

    describe "#path" do
      it "ファイルがアップロードされているパスが返ること" do
        path = File.join(Settings.files.upload_file.dir_path, content.id.to_s)
        expect(content.path).to eq(path)
      end
    end

    describe "#formatted_value" do
      let(:el){create(:element_by_it_upload_file)}
      let(:tr){create(:template_record)}
      let(:label){"2014年度予算"}
      let(:filename){"yosan.xls"}
      let(:result){"#{label}(#{filename})"}
      subject{content.formatted_value}

      context "selfがラベルのレコードの場合" do
        before do
          content.stub(:value){label}
          create(:element_value, element_id: el.id, record_id: tr.id, content: content, kind: ElementValue::KINDS[:upload_file][:label])
          file_c = create(:element_value_upload_file, value: filename)
          create(:element_value, element_id: el.id, record_id: tr.id, content: file_c, kind: ElementValue::KINDS[:upload_file][:file])
        end

        it "ラベル(ファイル名）の形式で文字列が返ること" do
          expect(subject).to eq(result)
        end
      end

      context "selfがファイルのレコードの場合" do
        before do
          content.stub(:value){filename}
          create(:element_value, element_id: el.id, record_id: tr.id, content: content, kind: ElementValue::KINDS[:upload_file][:file])
          file_c = create(:element_value_upload_file, value: label)
          create(:element_value, element_id: el.id, record_id: tr.id, content: file_c, kind: ElementValue::KINDS[:upload_file][:label])
        end
        
        it "ラベル(ファイル名）の形式で文字列が返ること" do
          expect(subject).to eq(result)
        end
      end
      
    end
    
  end
end
