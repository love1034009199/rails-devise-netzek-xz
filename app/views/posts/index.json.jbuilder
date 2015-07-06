json.array!(@posts) do |post|
  json.extract! post, :id, :user_name, :user_email, :user_remark
  json.url post_url(post, format: :json)
end
