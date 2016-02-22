require 'spec_helper'

describe Sengu::VDB::Domain do
  describe "メソッド" do
    describe '.domain_id' do
      it "'domain'を返すこと" do
        expect(Sengu::VDB::Domain.domain_id).to eq(Sengu::VDB::Domain::DOMAIN_ID)
      end
    end

    describe ".url_base" do
      it "domain用のURLが返ること" do
        vdb = Settings.vdb
        url = URI.join(vdb.server.host, vdb.server.path, "v#{vdb.version}/", "#{vdb.project_id}/", "#{Sengu::VDB::Domain::DOMAIN_ID}/")
        expect(Sengu::VDB::Domain.url_base).to eq(url)
      end
    end

    describe ".human_readable_name" do
      context "設定に定義されている場合" do
        it "core用の名前が返ること" do
          Settings.stub_chain(:vdb, :domain_name, Sengu::VDB::Domain::DOMAIN_ID) { "core_name" }
          expect(Sengu::VDB::Domain.human_readable_name).to eql("core_name")
        end
      end

      context "設定に定義されていない場合" do
        describe "domain_nameが定義されていない場合" do
          it "空文字が返る" do
            Settings.stub_chain(:vdb, :domain_name) { nil }
            expect(Sengu::VDB::Domain.human_readable_name).to eql("")
          end
        end

        describe "DOMAIN_IDが定義されていない場合" do
          it "空文字が返る" do
            Settings.stub_chain(:vdb, :domain_name, Sengu::VDB::Domain::DOMAIN_ID) { nil }
            expect(Sengu::VDB::Domain.human_readable_name).to eql("")
          end
        end
      end
    end
  end
end
