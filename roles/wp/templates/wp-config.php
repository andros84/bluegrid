<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wp_blue_db' );

/** MySQL database username */
define( 'DB_USER', 'blue' );

/** MySQL database password */
define( 'DB_PASSWORD', 'BlueGrid#2403' );

/** MySQL hostname */
define( 'DB_HOST', '' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'Z,D fOJ!i3AU4Qax][Ld<=Qf)G%N6!vR<8`0nHFJTcc*@>X?,]E|fI,<-*55:8I<' );
define( 'SECURE_AUTH_KEY',  'Zy97rDMf::rFr(N!@_acz>J*Z}tI.E|Nj!.d$0}bx_&nH6 MwG*rzLH@%j)]8+O`' );
define( 'LOGGED_IN_KEY',    '3v~(=bNL]!@H/ibiYPGfP#{.3`,28X;p~U0I}=f bW~[F~QC:T)A)X?jxJTPB`c<' );
define( 'NONCE_KEY',        '%=]r4;D8t_jxst~,fkF;kXCRP_o`2M#r[5 $,wHF_XByBJRhg9FBe&lNNwyOY.1A' );
define( 'AUTH_SALT',        'Wo@ @?A,@8#=LSM,^mS)aaJK 8^R%+nsmmLM8]W1g`gbzk3J-`p]K!Q%&PQ 9|6@' );
define( 'SECURE_AUTH_SALT', '^zkcav0sHtxt3.!vM,hn&, MZ#Nv7l$Rj? 1SD6hg4J}M3{TKQ@PePOf7dRVc|4,' );
define( 'LOGGED_IN_SALT',   'L1&.l>p wRt0&9<3(r}K;qR3dg<~I<Ixqts,$1M}u#}r@PM+QVgv%>h@I|h!]/oP' );
define( 'NONCE_SALT',       '`tQ*ZA_=;htl!-vn%7V_zYC#6Cfj6+kfIFCA[+UQ5H(!jH5gPXg3rll_!lv:P~ZH' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );