package 'nginx'

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :start
end

# Get all app server nodes
if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  app_servers = search(:node, 'role:"app"')
end

# Create the nginx vhost config
template '/etc/nginx/sites-available/default' do
  source  'nginx.conf.erb'
  owner   'root'
  group   'root'
  mode    '0644'
  variables(
    :app_servers => app_servers
  )
  notifies :restart, 'service[nginx]'
end
