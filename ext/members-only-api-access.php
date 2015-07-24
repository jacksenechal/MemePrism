<?php
/*
Plugin Name: Members Only API Access
Description: Allow XMLRPC API access for Members Only Plugin
Version: 1.0
Author: Citizen Code
Author URI: https://github.com/citizencode/MemePrism
*/


/*
Installation: Drop into wordpress_dir/wp-content/plugins/
Remember to activate plugin in the wp-admin interface.
------------------------------------------------------------ */
register_meta( 'post', '_wpac_is_members_only', 'custom_sanitize_as_is', 'custom_auth_always_allow');

function custom_sanitize_as_is( $meta_value, $meta_key, $meta_type ) {
  return $meta_value;
}

function custom_auth_always_allow( $allowed, $meta_key, $post_id, $user_id, $cap, $caps ) {
	return true;
}

?>
