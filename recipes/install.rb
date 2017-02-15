#
# Cookbook Name:: dokku
# Recipe:: install
#
# Copyright (c) 2015 Nick Charlton, MIT licensed.

include_recipe "dokku::_nginx"
include_recipe "openssl"

package "wget"
package "apt-transport-https"

docker_service "default" do
  action [:create, :start]
end

template "/etc/apt/sources.list.d/dokku.list" do
  source "apt.erb"
  cookbook "dokku"
  mode "0644"
  variables :base_url     => "https://packagecloud.io/dokku/dokku/ubuntu/",
            :distribution => "trusty",
            :component    => "main"

  notifies :run, "execute[apt-key-add-dokku]", :immediately
  notifies :run, "execute[apt-get-update-dokku]", :immediately
end

execute "apt-key-add-dokku" do
  command "wget --auth-no-challenge -qO - https://packagecloud.io/gpg.key | apt-key add -"
  action :nothing
end

execute "apt-get-update-dokku" do
  command "apt-get update -o Dir::Etc::sourcelist=\"sources.list.d/dokku.list\"" \
          " -o Dir::Etc::sourceparts=\"-\"" \
          " -o APT::Get::List-Cleanup=\"0\""
  action :nothing
end

package "dokku"

execute "install-dokku-plugin-core-dependencies" do
  command "dokku plugin:install-dependencies --core"
  action :run
end

file "/home/dokku/VHOST" do
  content node["dokku"]["domain"] || node["fqdn"]
end

openssl_dhparam node["dokku"]["nginx"]["dhparam_file"] do
  key_length node["dokku"]["nginx"]["dhparam_key_length"]

  notifies :restart, "service[nginx]", :delayed
end

dokku_nginx_template "global"
