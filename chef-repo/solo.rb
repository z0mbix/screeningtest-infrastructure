base = File.expand_path('..', __FILE__)

nodes_path                File.join(base, 'nodes')
cookbook_path             File.join(base, 'cookbooks')
role_path                 File.join(base, 'roles')
data_bag_path             File.join(base, 'data_bags')
encrypted_data_bag_secret File.join(base, 'data_bag_key')
environment_path          File.join(base, 'environments')
ssl_verify_mode           :verify_peer
file_cache_path           "/var/cache/chef-solo"

