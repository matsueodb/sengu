namespace :kokudo do
  desc "国土地理院の発行する位置参照情報から、senguで使用する位置データを作成する"
  task insert: :environment do
    unless ENV['DIR']
      puts "環境変数として、DIR=csvファイルが置かれたディレクトリ、を指定して実行してください"
      exit
    end

    unless File.exists? ENV['DIR']
      puts "指定されたディレクトリがありません"
      exit
    end

    csv_files = Dir.glob(File.join(ENV['DIR'], "*.csv"))
    if csv_files.blank?
      puts "指定されたディレクトリにcsvファイルがありません"
      exit
    end

    # 都道府県名と、idのマッピング {"島根県" => 1, "鳥取県" => 2}
    pref_id_mapping = { }

    # 市区町村名と、idのマッピング {1 => {"松江市" => 1, "出雲市" => 2}, 2 => {"米子市" => 3}}
    city_id_mapping = Hash.new {|hash, key| hash[key] = {}}

    # 住所と、idのマッピング {1 => [{:id => 1, :street => "学園南二", :latitude => "...", :longitude => "..." }, ...], ...}
    address_id_mapping = Hash.new {|hash, key| hash[key] = []}

    # 各idの現在値
    current_pref_id = 1
    current_city_id = 1
    current_address_id = 1

    csv_files.each do |file|
      CSV.foreach(file, encoding: "Shift_JIS", headers: true, return_headers: false) do |row|
        pref = row[0]
        city = row[1]
        street = row[2] + row[3]
        latitude = row[7]
        longitude = row[8]

        unless pref_id_mapping[pref]
          pref_id_mapping[pref] = current_pref_id
          current_pref_id += 1
        end

        pref_id = pref_id_mapping[pref]
        if city_id_mapping[pref_id].blank? || city_id_mapping[pref_id][city].blank?
          city_id_mapping[pref_id].merge!({city => current_city_id })
          current_city_id += 1
        end

        city_id = city_id_mapping[pref_id][city]
        address_id_mapping[city_id] << {id: current_address_id, street: street, latitude: latitude, longitude: longitude}
        current_address_id += 1
      end
    end

    query = ""
    pref_id_mapping.each do |pref, id|
      query << "#{id},#{pref}\n"
    end
    execute_copy(KokudoPref, %w(id name), query)

    query = ""
    city_id_mapping.each do |pref_id, hash|
      hash.each do |city_name, city_id|
        query << "#{city_id},#{city_name},#{pref_id}\n"
      end
    end
    execute_copy(KokudoCity, %w(id name pref_id), query)


    query = ""
    address_id_mapping.each do |city_id, array|
      array.each do |hash|
        query << "#{hash[:id]},#{hash[:street]},#{hash[:latitude]},#{hash[:longitude]},#{city_id}\n"
      end
    end
    execute_copy(KokudoAddress, %w(id street latitude longitude city_id), query)
  end
end

def execute_copy(model, headers, query)
  conn = model.connection.raw_connection

  conn.exec( %{
            COPY #{model.table_name} ( #{headers.join(',')} ) FROM STDIN WITH CSV
          })
  conn.put_copy_data(query)
  conn.put_copy_end
end
