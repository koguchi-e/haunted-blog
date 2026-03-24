json.users @users do |user|
  json.nickname user.nickname
end
json.destroy_path @destroy_path
