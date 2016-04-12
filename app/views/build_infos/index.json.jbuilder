json.array!(@build_infos) do |build_info|
  json.extract! build_info, :id, :display, :colour, :time
  json.url build_info_url(build_info, format: :json)
end
