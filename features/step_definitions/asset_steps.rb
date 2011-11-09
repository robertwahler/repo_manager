Given /^the folder "([^"]*)" with the following asset configurations:$/ do |folder, table|
  create_dir(folder) unless File.exists?(File.join(current_dir, folder))

  table.hashes.each do |hash|
    config = {}
    config.merge!('path' => hash[:path]) if hash[:path]
    config.merge!('parent' => hash[:parent]) if hash[:parent]
    config.merge!('binary' => hash[:binary]) if hash[:binary]

    asset_name = hash[:name]
    create_dir(File.join(folder, asset_name))

    filename = File.join(folder, asset_name, 'asset.conf')
    write_file(filename, config.to_yaml)
  end

end

