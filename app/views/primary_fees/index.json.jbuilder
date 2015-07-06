json.array!(@primary_fees) do |primary_fee|
  json.extract! primary_fee, :id, :primary_name, :primary_description, :primary_configure, :primary_remark
  json.url primary_fee_url(primary_fee, format: :json)
end
