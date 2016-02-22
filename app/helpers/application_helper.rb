module ApplicationHelper

  #
  #=== アラートタグを出力する
  #
  #  ex.) <%= alert_tag(type: 'success', messages: ['success update!'] %>
  #
  def alert_tag(options = {})
    type = options.delete(:type) || "danger"
    if block_given?
      content_tag(:div, options.merge(class: "alert alert-#{type}")) do
        yield
      end
    end
  end

  #
  #=== モデルのエラーメッセージを表示する
  #
  def error_messages_for(resource)
    messages = resource.errors.full_messages.uniq
    render_error_messages(messages)
  end

  #
  #=== アイコン付きのリンクタグの作成
  #
  # ex.) <%= link_to_with_icon 'リンク',  '#', icon: 'trash' %>
  #
  def link_to_with_icon(text, path, options={})
    icon = options.delete(:icon)
    link_to(path, options) do
      concat(content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}")) if icon
      concat("&nbsp;#{text}".html_safe)
    end
  end

  #
  #=== アイコン付きのボタンタグの作成
  #
  # ex.) <%= button_tag_with_icon 'ボタン', class: 'btn btn-default', icon: 'trash' %>
  #
  def button_tag_with_icon(text, options={})
    options = {type: 'submit'}.merge(options)
    icon = options.delete(:icon)
    button_tag(text, options) do
      concat(content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}")) if icon
      concat("&nbsp;#{text}".html_safe)
    end
  end

  #
  #=== ページタイトルをI18nで変換して返す。
  #
  def page_title(attr={})
    return "" if @page_title_off
    return @page_title if @page_title
    c_name = params[:controller].split(/\//).join(".")
    a_name = params[:action]
    @page_title = I18n.t("#{c_name}.#{a_name}.title", attr)
  end

  #
  #=== 戻るボタンを表示する
  #
  def link_to_back(url, options = {})
    klass = "btn btn-warning"
    klass += " #{options[:class]}" if options[:class]
    link_to_with_icon t("shared.back"), url, options.merge(class: klass, icon: "circle-arrow-left")
  end

  #
  #=== キャンセルボタンを表示する
  #
  def link_to_cancel(url, options = {})
    klass = "btn btn-warning"
    klass += " #{options[:class]}" if options[:class]
    link_to_with_icon t("shared.cancel"), url, options.merge(class: klass, icon: "ban-circle")
  end

  #
  #=== 削除ボタンを表示する。
  #
  def link_to_destroy(url, options ={})
    defaults = {data: {confirm: t("shared.confirm.destroy")}, method: :delete, icon: "trash"}
    klass = "btn btn-danger"
    klass += " #{options.delete(:class)}" if options[:class]
    defaults.merge!(class: klass)
    link_to_with_icon t("shared.destroy"), url, defaults.merge(options)
  end

  #
  #=== 改行コードをbrタグにかえる
  #
  def hbr(str)
    str = html_escape(str)
    raw str.gsub(/\r\n|\r|\n/, "<br />")
  end

  #
  #=== 引数で渡されたテンプレートが拡張であれば、拡張ラベルを返却する
  #
  def template_extension_label(template)
    if template.has_parent?
      content_tag(:span, t('shared.extension'), class: 'label label-info')
    end
  end

  #
  #=== 引数で渡されたテンプレートが非公開であれば、非公開ラベルを返却する
  #
  def template_unpublish_label(template)
    if template.close?
      content_tag(:span, t('shared.unpublish'), class: 'label label-danger')
    end
  end

  #
  #=== 引数で渡された文字がnilならば'なし'と返却する
  #
  def none_text(text=nil)
    text.blank? ? t('shared.none') : text
  end

  #
  #=== ページネーション情報表示
  def paginate_info(collection)
    # kaminari参照
    first = collection.total_count.zero? ? 0 : collection.offset_value + 1
    last = collection.last_page? ? collection.total_count : collection.offset_value + collection.limit_value
    t('helpers.paginate_info.more_pages.display_entries', first: first, last: last, total: collection.total_count)
  end

  #
  #=== ◯ or ×を返す
  def boolean_icon(bool, tooltip_text = "")
    cname = bool ? "text-success" : "text-danger"
    attr = {class: ["boolean_icon", cname]}
    if tooltip_text.present?
      attr[:class] << "static-tooltip-description"
      attr[:data] = {toggle: "tooltip", placement: "top", "original-title" => tooltip_text}
    end
    content_tag(:strong, attr){bool ? "○" : "×"}
  end

  #
  #=== 必須入力を表すアイコンを表示
  def required_icon
    content_tag(:span, "", class: "glyphicon glyphicon-asterisk text-danger")
  end

  #
  #=== エンジンの機能へのリンクをナビゲーションに表示する
  def navigations_for_engine
    settings = Dir.glob(File.join(Rails.root, "vendor/engines/*")).map do |engine_path|
      engine_name = File.basename(engine_path)
      Settings[engine_name].try(:navigations)
    end.compact.flatten
    settings.map do |setting|
      content_tag(:li) { link_to_with_icon setting.title, setting.href, icon: setting.icon }
    end.join("\n").html_safe
  end

private

  #
  #=== エラーメッセージを表示する
  def render_error_messages(messages)
    if messages.present?
      alert_tag do
        content_tag(:ul) do
          messages.each do |m|
            concat(content_tag(:li) {simple_format(m)})
          end
        end
      end
    end
  end
end
