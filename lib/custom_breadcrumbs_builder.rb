class CustomBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  def render
    @context.render "/shared/breadcrumbs", elements: @elements, builder: self
  end

  # REF: gems/breadcrumbs_on_rails-2.3.0/lib/breadcrumbs_on_rails/breadcrumbs.rb
  def compute_name(element)
    case name = element.name
    when Symbol
      @context.send(name)
    when Proc
      name.call(@context)
    else
      name.to_s
    end
  end

  def compute_path(element)
    case path = element.path
    when Symbol
#      @context.send(path)
#    本来は上記の処理だが、add_breadcrumb I18n.t("shared.top"), :rootのような形で呼んでいる箇所があるので、合わせている
      path
    when Proc
      path.call(@context)
    else
      @context.url_for(path)
    end
  end
end
