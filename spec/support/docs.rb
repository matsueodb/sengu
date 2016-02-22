def capture_path(file_name='screenshot')
  path = Rails.root.join("doc", "captures", "#{file_name}.png")
  FileUtils.mkdir_p File.dirname(path)
  path
end
