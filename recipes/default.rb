#
# Cookbook Name:: k8s
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

chef_gem 'kubeclient' do 
  version node['k8s']['client_version']
  compile_time true if Chef::Resource::ChefGem.instance_methods(false).include?(:compile_time)
  action :install
end