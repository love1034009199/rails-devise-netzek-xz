json.array!(@discount_fees) do |discount_fee|
  json.extract! discount_fee, :id, :discount_name, :discount_description, :discount_configure, :discount_remark
  json.url discount_fee_url(discount_fee, format: :json)
end
