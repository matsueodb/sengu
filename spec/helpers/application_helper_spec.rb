require 'spec_helper'

describe ApplicationHelper do
  describe "#alert_tag" do
    let(:message) { 'test-message' }

    it "bootstrapのアラートタグの中に、ブロックで渡した文字列が含まれたhtmlが返ること" do
      expect(helper.alert_tag{message}).to eq(
        "<div class=\"alert alert-danger\">#{message}</div>"
      )
    end
  end

  describe "#error_messages_for" do
    let(:resource) { stub_model(User) }

    context "messagesがある場合" do
      let(:messages) { ['test'] }

      before do
        resource.stub_chain(:errors, :full_messages).and_return(messages)
      end

      it "エラーメッセージが整形されて返ること" do
        msg = %Q(<div class="alert alert-danger"><ul><li>#{simple_format('test')}</li></ul></div>)
        expect(helper.error_messages_for(resource)).to eq(msg)
      end
    end

    context "messagesがない場合" do
      let(:messages) { [] }

      before do
        resource.stub_chain(:errors, :full_messages).and_return(messages)
      end

      it "alert_tagが正しい引数で呼ばれいないこと" do
        helper.should_not_receive(:alert_tag)
        helper.error_messages_for(resource)
      end
    end

  end

  describe "#link_to_with_icon" do
    let(:title) { 'test' }
    let(:href) { '/' }
    let(:icon) { 'trash' }

    it "bootstrapのアイコン付きリンクタグを返すこと" do
      expect(helper.link_to_with_icon title, href, icon: icon ).to eq(
        "<a href=\"#{href}\"><span class=\"glyphicon glyphicon-#{icon}\"></span>&nbsp;#{title}</a>"
      )
    end
  end

  describe "#button_tag_with_icon" do
    let(:title) { 'test' }
    let(:icon) { 'trash' }

    it "bootstrapのアイコン付きリンクタグを返すこと" do
      expect(helper.button_tag_with_icon title, icon: icon ).to eq(
        "<button name=\"button\" type=\"submit\"><span class=\"glyphicon glyphicon-#{icon}\"></span>&nbsp;#{title}</button>"
      )
    end
  end

  describe "#page_title" do
    let(:c){"templates/contents"}
    let(:a){"index"}
    let(:title){I18n.t("templates.contents.index.title")}

    it "params[:controller]とparams[:action]をもとに、ページタイトルが返ること" do
      params.stub(:[]).with(:controller){c}
      params.stub(:[]).with(:action){a}
      expect(helper.page_title).to eq(title)
    end

    it "@page_title_offがある場合、空文字列が返ること" do
      helper.instance_eval do
        @page_title_off = true
      end
      expect(helper.page_title).to be_empty
    end

    it "@page_titleがある場合、その文字列が返ること" do
      helper.instance_eval do
        @page_title = "test page_title"
      end
      expect(helper.page_title).to eq("test page_title")
    end
  end

  describe "#link_to_back" do
    let(:url){root_path}
    let(:val){I18n.t("shared.back")}

    it 'class="btn btn-warning"と項目名に戻るが追加されたリンクタグが返ること' do
      result = %Q(<a class=\"btn btn-warning\" href=\"#{root_path}\"><span class=\"glyphicon glyphicon-circle-arrow-left\"></span>&nbsp;#{val}</a>)
      expect(helper.link_to_back(url)).to eq(result)
    end

    it "第２引数で渡したlinkオプションが適用されること" do
      result = %Q(<a class=\"btn btn-warning test\" href=\"#{root_path}\" id=\"example\"><span class=\"glyphicon glyphicon-circle-arrow-left\"></span>&nbsp;#{val}</a>)
      expect(helper.link_to_back(url, class: "test", id: "example")).to eq(result)
    end
  end

  describe "#link_to_cancel" do
    let(:url){root_path}
    let(:val){I18n.t("shared.cancel")}

    it 'class="btn btn-warning"と項目名にキャンセルが追加されたリンクタグが返ること' do
      result = %Q(<a class=\"btn btn-warning\" href=\"#{root_path}\"><span class=\"glyphicon glyphicon-ban-circle\"></span>&nbsp;#{val}</a>)
      expect(helper.link_to_cancel(url)).to eq(result)
    end

    it "第２引数で渡したlinkオプションが適用されること" do
      result = %Q(<a class=\"btn btn-warning test\" href=\"#{root_path}\" id=\"example\"><span class=\"glyphicon glyphicon-ban-circle\"></span>&nbsp;#{val}</a>)
      expect(helper.link_to_cancel(url, class: "test", id: "example")).to eq(result)
    end
  end

  describe "#link_to_destroy" do
    let(:url){root_path}
    let(:val){I18n.t("shared.destroy")}
    let(:confirm_destroy_val){I18n.t("shared.confirm.destroy")}

    it 'class="btn btn-danger"とdata-method="delete"とdata-confirm="削除しますか？"と項目名に削除が追加されたリンクタグが返ること' do
      result = %Q(<a class=\"btn btn-danger\" data-confirm="#{confirm_destroy_val}" data-method="delete" href=\"#{root_path}\" rel=\"nofollow\"><span class=\"glyphicon glyphicon-trash\"></span>&nbsp;#{val}</a>)
      expect(helper.link_to_destroy(url)).to eq(result)
    end

    it "第２引数で渡したlinkオプションが適用されること" do
      result = %Q(<a class=\"btn btn-danger test\" data-confirm="#{confirm_destroy_val}" data-method="delete" href=\"#{root_path}\" id=\"example\" rel=\"nofollow\"><span class=\"glyphicon glyphicon-trash\"></span>&nbsp;#{val}</a>)
      expect(helper.link_to_destroy(url, class: "test", id: "example")).to eq(result)
    end
  end

  describe "#hbr" do
    let(:before_str){"松江城とは松江にあるお城です。\n殿町にあります。\r\n周りにはお堀があります。\r遊覧船もあります。"}
    let(:after_str){"松江城とは松江にあるお城です。<br />殿町にあります。<br />周りにはお堀があります。<br />遊覧船もあります。"}

    subject{helper.hbr(before_str)}
    it "改行コードが<br />タグに置き換えられること" do
      expect(subject).to eq(after_str)
    end
  end

  describe "#template_extension_label" do
    let(:template){create(:template)}

    subject{helper.template_extension_label(template)}

    it "引数で渡したTemplateが拡張テンプレートでは無い場合、nilが返ること" do
      template.stub(:has_parent?){false}
      expect(subject).to be_nil
    end

    it "引数で渡したTemplateが拡張テンプレートの場合、拡張ラベルのspanタグが返ること" do
      template.stub(:has_parent?){true}
      str = %Q(<span class="label label-info">#{t('shared.extension')}</span>)
      expect(subject).to eq(str)
    end
  end

  describe "#template_unpublish_label" do
    let(:template){create(:template)}

    subject{helper.template_unpublish_label(template)}

    it "引数で渡したTemplateの状態が非公開では無い場合、nilが返ること" do
      template.stub(:close?){false}
      expect(subject).to be_nil
    end

    it "引数で渡したTemplateの状態が非公開の場合、拡張ラベルのspanタグが返ること" do
      template.stub(:close?){true}
      str = %Q(<span class="label label-danger">#{t('shared.unpublish')}</span>)
      expect(subject).to eq(str)
    end
  end

  describe "#none_text" do
    it "引数で渡した値がnilの場合、なしと表示すること" do
      expect(helper.none_text(nil)).to eq(I18n.t("shared.none"))
    end

    it "引数で渡した値がnilでは無い場合、そのまま返すこと" do
      expect(helper.none_text("松江")).to eq("松江")
    end
  end

  describe "#paginate_info" do
    let(:str){I18n.t("helpers.paginate_info.more_pages.display_entries", total: 30, first: 11, last: 20)}
    let(:collection){Kaminari.paginate_array((1..30).to_a).page(2).per(10)}

    subject{helper.paginate_info(collection)}

    it "ページネーション情報が返ること" do
      expect(subject).to eq(str)
    end
  end

  describe "#boolean_icon" do
    let(:enable){'<strong class="boolean_icon text-success">○</strong>'}
    let(:disable){'<strong class="boolean_icon text-danger">×</strong>'}

    it "引数でtrueを渡した場合、○が返ること" do
      expect(helper.boolean_icon(true)).to eq(enable)
    end

    it "引数でfalseを渡した場合、×が返ること" do
      expect(helper.boolean_icon(false)).to eq(disable)
    end
  end

  describe "#required_icon" do
    let(:icon){'<strong class="text-danger">（必須項目）</strong>'}

    it "必須入力を表すアイコンのHTMLが返ること" do
      expect(helper.required_icon).to eq(icon)
    end
  end

  describe "#navigations_for_engine" do
    let(:title) { 'test' }
    let(:href) { '/' }
    let(:icon) { 'trash' }
    let(:engine_path){ File.join(Rails.root, "vendor/engines/test_engine") }
    let(:setting) { double("setting", title: title, href: href, icon: icon) }

    it "エンジンへのリンクが返ること" do
      allow(Dir).to receive(:glob).and_return([engine_path])
      Settings.stub_chain(File.basename(engine_path).to_sym, :navigations).and_return([setting])
      expect(helper.navigations_for_engine).to eq(
        "<li><a href=\"#{href}\"><span class=\"glyphicon glyphicon-#{icon}\"></span>&nbsp;#{title}</a></li>"
      )
    end
  end

  describe "private" do
    describe "#render_error_messages" do
      context "messagesがある場合" do
        let(:messages) { ['test'] }

        it "エラーメッセージが整形されて返ること" do
          msg = %Q(<div class="alert alert-danger"><ul><li>#{simple_format('test')}</li></ul></div>)
          expect(helper.send(:render_error_messages, messages)).to eq(msg)
        end
      end

      context "messagesがない場合" do
        let(:messages) { [] }

        it "alert_tagが正しい引数で呼ばれいないこと" do
          helper.should_not_receive(:alert_tag)
          helper.send(:render_error_messages, messages)
        end
      end
    end
  end
end
