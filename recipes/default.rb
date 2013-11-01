
home_dir = node.django.home_dir
username = node.django.username
group = node.django.group
log_dir = node.django.log_dir

user username do
  system true
  uid 324 # "reserved" for this user
  shell '/bin/bash'
  comment 'system account'
  home home_dir
  supports :manage_home => true
  action :create
end

directory home_dir do
  user username
  group username
  mode 0755
end

sudo username do
  user username
  nopasswd true
  commands ['/usr/bin/chef-client',
            '/sbin/restart django-server',
            '/sbin/start django-server',
            '/sbin/stop django-server']
end

# create a log directory writeable by the user

directory log_dir do
  user username
  group group
  mode 0755
end

# always install these packages
package 'fail2ban'
package 'python-setuptools'
package 'python-pip'
