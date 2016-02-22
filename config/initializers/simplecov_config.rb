# NOTE: 計測対象のファイルが先に読み込まれると計測されないので、なるべく先にstartさせるためにinitializerの下に置いた
if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  require 'simplecov-csv'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CSVFormatter
  ]
  SimpleCov.start 'rails'
end
