
username = node.django.username
group = node.django.group
deploy_dir = node.django.deploy_dir
log_dir = node.django.log_dir
git_url = node.django.app.git_url
commit = node.django.app.git_commit

# required packages
package 'python-virtualenv'
package 'python-pip'
package 'python-dev'

git deploy_dir do
  user username
  group group
  repository git_url
  reference commit
  enable_submodules true
  action :checkout
end

directory log_dir do
  user username
  group group
  mode 0755
end

# generate django secret key and write it to disk
require 'securerandom'

file "#{deploy_dir}/.secret_key" do
  owner username
  group group
  mode 0600
  content SecureRandom.base64(128)
  action :nothing
end

# write out local settings for db access, etc.

template "#{deploy_dir}/local_settings.py" do
  user username
  group group
  mode 0644
  source 'local_settings.py.erb'
  variables :debug => node.django.debug,
            :db_name => node.django.database.name,
            :db_user => node.django.database.user,
            :db_password => node.django.database.password
end

# virtualenv setup

bash 'django-virtualenv' do
  user username
  group group
  cwd deploy_dir
  code "virtualenv --distribute venv"
  creates "#{deploy_dir}/venv"
  action :nothing
end

bash 'django-pip-install' do
  user username
  group group
  cwd deploy_dir
  code "source venv/bin/activate && pip install -r requirements.txt"
  action :nothing
end

# write out upstart daemon
template '/etc/init/django-server.conf' do
  user 'root'
  group 'root'
  mode 0644
  source 'django-server.conf.erb'
  variables :home => node.django.home_dir,
            :django_home => deploy_dir,
            :port => node.django.worker_port,
            :bind => node.django.bind_address,
            :workers => node.django.num_workers,
            :log_dir => node.django.log_dir,
            :log_level => node.django.log_level
  notifies :restart, "service[django-server]", :delayed
end

service 'django-server' do
  provider Chef::Provider::Service::Upstart
  action [:enable]
end

# nginx configuration
include_recipe 'django::nginx'

nginx_site 'django' do
  template 'nginx-server.conf.erb'
  vars :server_root => node.django.nginx.server_root,
       :http_port => node.django.nginx.http_port
end
