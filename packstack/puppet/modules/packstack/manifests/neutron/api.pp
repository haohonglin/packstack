class packstack::neutron::api ()
{
    create_resources(packstack::firewall, hiera('FIREWALL_NEUTRON_SERVER_RULES', {}))

    $neutron_db_host         = hiera('CONFIG_MARIADB_HOST_URL')
    $neutron_db_name         = hiera('CONFIG_NEUTRON_L2_DBNAME')
    $neutron_db_user         = 'neutron'
    $neutron_db_password     = hiera('CONFIG_NEUTRON_DB_PW')
    $neutron_sql_connection  = "mysql+pymysql://${neutron_db_user}:${neutron_db_password}@${neutron_db_host}/${neutron_db_name}"
    $neutron_user_password   = hiera('CONFIG_NEUTRON_KS_PW')
    $neutron_fwaas_enabled   = str2bool(hiera('CONFIG_NEUTRON_FWAAS'))
    $neutron_lbaas_enabled   = str2bool(hiera('CONFIG_LBAAS_INSTALL'))
    $neutron_vpnaas_enabled  = str2bool(hiera('CONFIG_NEUTRON_VPNAAS'))

    class { '::neutron::server':
      database_connection   => $neutron_sql_connection,
      password              => $neutron_user_password,
      auth_uri              => hiera('CONFIG_KEYSTONE_PUBLIC_URL'),
      auth_url              => hiera('CONFIG_KEYSTONE_ADMIN_URL'),
      sync_db               => true,
      enabled               => true,
      api_workers           => hiera('CONFIG_SERVICE_WORKERS'),
      rpc_workers           => hiera('CONFIG_SERVICE_WORKERS'),
      service_providers     => hiera_array('SERVICE_PROVIDERS'),
      ensure_fwaas_package  => $neutron_fwaas_enabled,
      ensure_vpnaas_package => $neutron_vpnaas_enabled,
      ensure_lbaas_package  => $neutron_lbaas_enabled,
    }

    file { '/etc/neutron/api-paste.ini':
      ensure  => file,
      mode    => '0640',
    }

    Class['::neutron::server'] -> File['/etc/neutron/api-paste.ini']
}
