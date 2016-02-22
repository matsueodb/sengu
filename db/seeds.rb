# coding: utf-8
class ActiveRecord::Base
  # 指定された :id があれば update する。なければ create。
  def self.create_or_update(options = {})
    options = options.with_indifferent_access
    id = options.delete(self.primary_key)
    if self.exists?(id)
      record = find(id)
      record = record.update_attributes!(options)
    else
      record = self.create(options.merge(self.primary_key => id))
      puts record.errors.full_messages
    end
    record
  rescue ActiveRecord::ActiveRecordError => ex
    puts "ERROR: #{ex.class} : #{ex.message}"
    Rails.logger.error "ERROR: #{ex.class} : #{ex.message}"
    raise ex
  end
end

# DBマスターデータロード
require 'active_record/fixtures'
require 'csv'

ActiveRecord::Base.transaction do
  fixtures = Dir.glob(File.join(Rails.root, 'db', 'fixtures', '**', '*.{yml}'))
  fixtures += Dir.glob(File.join(Rails.root, 'vendor', 'engines', '*', 'db', 'fixtures', '**', '*.{yml}'))
  fixtures.sort_by! { |s| File.basename(s) }

  fixtures.each do |fixture_file|
    # NOTE: ファイルのロード順があるので、prefixをymlに設定
    if f_name = File.basename(fixture_file, '.*').match(/([0-9]+_)(.*)/)
      tname = f_name[2]
      dirname = File.basename(File.dirname(fixture_file))
      if dirname == 'fixtures'
        table = tname.singularize.camelize.constantize
      else
        # NOTE: modelがnamespaceで区切られている場合は、fixtures以下も同様にnamespaceで区切る
        table = (dirname.camelize + "::" + tname.singularize.camelize).constantize
      end

      puts "===== start #{tname} ====="
      records = YAML.load(ERB.new(IO.read(fixture_file)).result)
      records.each do |key, record|
        table.create_or_update(record)
        # === DBのIDの連番値を更新
        if table.column_names.include?("id")
          table.connection.execute("SELECT SETVAL('#{table.table_name}_id_seq', (SELECT MAX(id) FROM #{table.table_name}));")
        end
      end
      puts "===== finish #{tname} ====="
    end
  end
end
