# == Schema Information
#
# Table name: regular_expressions
#
#  id       :integer          not null, primary key
#  name     :string(255)
#  format   :string(255)
#  option   :string(255)
#  editable :boolean          default(TRUE)
#

class RegularExpression < ActiveRecord::Base
  validates :name, presence: true, length: {maximum: 255}, uniqueness: true
  validates :format, presence: true, length: {maximum: 255}
  validates :option,
    length: {maximum: 3},
    format: {with: /\A(m(xi?|ix?)?|x(mi?|im?)?|i(xm?|mx?)?)\z/, :if => Proc.new{self.option.present?}}

  OPTIONS = {
    "i" => Regexp::IGNORECASE,
    "x" => Regexp::EXTENDED,
    "m" => Regexp::MULTILINE
  }

  has_many :elements

  #
  #=== formatとoptionを複合した形で返す．
  #==== 戻り値
  # * String(Rubyの正規表現の形)
  def formatted
    "/#{self.format}/#{self.option}"
  end

  #
  #=== formatとoptionを複合した形でRegexpインスタンスを返す．
  #==== 戻り値
  # * Regexp(self.formatted)
  def to_regexp
    Regexp.new(self.format, option_value)
  end

  #
  #=== 削除できるかを返す
  #==== 戻り値
  # * true: 削除可能, false: 削除不可
  def destroyable?
    editable?
  end

  private

    #
    #=== optionの値をRegexpクラスで使用する値に変換
    def option_value
      return nil if self.option.blank?
      self.option.to_s.split("").map{|o|OPTIONS[o]}.sum
    end
end
