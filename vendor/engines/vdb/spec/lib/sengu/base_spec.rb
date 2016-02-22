require 'spec_helper'

describe Sengu::VDB::Base do
  describe "メソッド" do
    describe ".find" do
      let(:getname) { '人型' }
      let(:success_response) {
        double('response', code: '200')
      }

      it "Sengu::VDB::Response.parseを正しい引数で呼び出していること" do
        allow(Sengu::VDB::Base).to receive(:get_vocabulary).and_return(success_response)
        expect(Sengu::VDB::Response).to receive(:parse).with(success_response, Sengu::VDB::Base.domain_id, getname)
        Sengu::VDB::Base.find(getname, true)
      end

      context "関連先を取得する場合" do
        let(:flg) { true }

        before do
          expect(Sengu::VDB::Base).to receive(:get_vocabulary).with(
            Settings.vdb.api_ids.find_id,
            getname: getname,
            relateflg: Sengu::VDB::Base::RELATE_FLGS[flg]
          )
        end

        it ".get_vocabularyを正しい引数で呼び出していること" do
          Sengu::VDB::Base.find(getname, flg)
        end
      end

      context "関連先を取得しない場合" do
        let(:flg) { false }

        before do
          expect(Sengu::VDB::Base).to receive(:get_vocabulary).with(
            Settings.vdb.api_ids.find_id,
            getname: getname,
            relateflg: Sengu::VDB::Base::RELATE_FLGS[flg]
          )
        end

        it ".get_vocabularyを正しい引数で呼び出していること" do
          Sengu::VDB::Base.find(getname, flg)
        end
      end
    end

    describe ".all" do
      let(:success_response) {
        double('response', code: '200')
      }

      before do
        expect(Sengu::VDB::Base).to receive(:get_vocabulary).with(Settings.vdb.api_ids.all_id)
      end

      it ".get_vocabularyを正しい引数で呼び出していること" do
        Sengu::VDB::Base.all
      end

      it "Sengu::VDB::Response.parseを正しい引数で呼び出していること" do
        allow(Sengu::VDB::Base).to receive(:get_vocabulary).and_return(success_response)
        expect(Sengu::VDB::Response).to receive(:parse).with(success_response, Sengu::VDB::Base.domain_id)
        Sengu::VDB::Base.all
      end
    end

    describe ".search" do
      let(:success_response) {
        double('response', code: '200')
      }
      let(:getname) { '人' }

      before do
        expect(Sengu::VDB::Base).to receive(:get_vocabulary).with(
          Settings.vdb.api_ids.search_id,
          getname: getname
        )
      end

      it ".get_vocabularyを正しい引数で呼び出していること" do
        Sengu::VDB::Base.search(getname)
      end

      it "Sengu::VDB::Response.parseを正しい引数で呼び出していること" do
        allow(Sengu::VDB::Base).to receive(:get_vocabulary).and_return(success_response)
        expect(Sengu::VDB::Response).to receive(:parse).with(success_response, Sengu::VDB::Base.domain_id, getname)
        Sengu::VDB::Base.search(getname)
      end

    end

    describe ".url_base" do
      it "アクセス先URLのベースを返すこと" do
        vdb = Settings.vdb
        url = URI.join(vdb.server.host, vdb.server.path, "v#{vdb.version}/", "#{vdb.project_id}/", "#{Sengu::VDB::Base.domain_id}/")
        expect(Sengu::VDB::Base.url_base).to eq(url)
      end
    end

    describe ".get_vocabulary" do
      let(:getname) { '人型' }
      let(:success_response) {
        double('response', code: '200')
      }

      it "正しいURLでgetをしていること" do
        url = URI.join(Sengu::VDB::Base.url_base, Settings.vdb.api_ids.find_id)
        url.query = URI.encode_www_form({
          getname: getname,
          relateflg: Sengu::VDB::Base::RELATE_FLGS['1']
        }.to_a).force_encoding('utf-8')

        expect_any_instance_of(Net::HTTP).to receive(:get).with(
          "#{url.path}?#{url.query}"
        ).and_return(success_response)
        allow(Sengu::VDB::Response).to receive(:parse).and_return(true)

        Sengu::VDB::Base.get_vocabulary(
          Settings.vdb.api_ids.find_id,
          getname: getname,
          relateflg: Sengu::VDB::Base::RELATE_FLGS['1']
        )
      end

      it "Sengu::VDB::Response.parseの返り値がhttpのレスポンスであること" do
        allow_any_instance_of(Net::HTTP).to receive(:get).and_return(success_response)

        vdb_response = Sengu::VDB::Base.get_vocabulary(
          Settings.vdb.api_ids.find_id,
          getname: getname,
          relateflg: Sengu::VDB::Base::RELATE_FLGS['1']
        )
        expect(vdb_response).to eq(success_response)
      end


      context "語彙の取得で例外が発生した場合" do
        before do
          allow_any_instance_of(Net::HTTP).to receive(:get).and_raise StandardError
        end

        it "Sengu::VDB::Base::ConnectionErrorを投げること" do
          expect {
            Sengu::VDB::Base.get_vocabulary(Settings.vdb.api_ids.find_id,
                                            getname: getname,
                                            relateflg: Sengu::VDB::Base::RELATE_FLGS['1'])
          }.to raise_error(Sengu::VDB::Base::ConnectionError)
        end
      end
    end

    describe ".domain_id" do
      it "'core'を返すこと" do
        expect(Sengu::VDB::Base.domain_id).to eq('core')
      end
    end
  end
end

