#
# Cookbook:: mongodb_cookbook_final
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.
include_recipe 'apt'


# Installing mongodb
bash 'install_mongod' do
  user 'root'
  code <<-EOH
  wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
  echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  sudo apt-get update
  sudo apt-get install -y mongodb-org=3.2.20 mongodb-org-server=3.2.20 mongodb-org-shell=3.2.20 mongodb-org-mongos=3.2.20 mongodb-org-tools=3.2.20
  sudo systemctl restart mongod
  sudo systemctl enable mongod.service
  EOH
end

execute 'restart_mongod' do
  command 'sudo systemctl restart mongod'
  action :nothing
end

execute 'restart_mongod.service' do
  command 'sudo systemctl enable mongod.service'
  action :nothing
end

# COnfigurations of MongoDB

template '/etc/mongod.conf' do
  source 'mongod.conf.erb'
  variables bind_ip: node['mongod']['bind_ip'], port: node['mongod']['port']
  notifies :run, 'execute[restart_mongod]', :immediately
end

template '/lib/systemd/system/mongod.service' do
  source 'mongod.service.erb'
  notifies :run, 'execute[restart_mongod.service]', :immediately
end
