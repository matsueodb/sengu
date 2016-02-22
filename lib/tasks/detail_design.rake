#
#=== Rails.root/doc以下にRDocのhtmlがある前提
# 事前に以下のコマンドの実行が必要
# rspec spec/features/**
# rake doc:app
#
require 'wicked_pdf'
require 'hpricot'
namespace :detail_design do
  desc "内部設計書の生成"
  task :generate => :environment do
    doc_path = Rails.root.join("doc")
    app_path = File.join(doc_path, "app")
    files = Dir.glob(File.join(app_path, "**", "*Controller.html"))
    generate_path = File.join(doc_path, "detial_design.pdf")
    
    css = File.read(File.join(app_path, "rdoc.css"))
    # 以下のスタイルをcssに追加する。
    # サイドメニューを消す
    css +=<<-ADD_HTML
    nav#metadata{display:none}
    div#documentation{margin:0}
ADD_HTML

    css = "<style>#{css}</style>"

    pdfs = files.map do |file_path|
      html = Hpricot(File.read(file_path))
      # headタグの中にcssの内容を追加
      head = html.search("head")
      head.inner_html += css

      html.search("img").each do |img|
        # 画像パスを絶対パスに変更。../の場合と、../../の場合がある
        src = img.attributes["src"].gsub("../..", doc_path.to_s)
        src.gsub!("..", doc_path.to_s)
        img.attributes["src"] = src
      end
      html
    end
    
    File.open(generate_path, 'wb') do |file|
      file << WickedPdf.new.pdf_from_string(pdfs.join("\n"))
    end
  end
end