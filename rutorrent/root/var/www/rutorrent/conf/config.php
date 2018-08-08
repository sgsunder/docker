<?php
  // configuration parameters

  // for snoopy client
  @define('HTTP_USER_AGENT', 'Mozilla/5.0 (Windows NT 6.0; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0', true);
  @define('HTTP_TIME_OUT', 30, true); // in seconds
  @define('HTTP_USE_GZIP', true, true);
  $httpIP = null; // IP string. Or null for any.

  @define('RPC_TIME_OUT', 5, true); // in seconds

  @define('LOG_RPC_CALLS', false, true);
  @define('LOG_RPC_FAULTS', true, true);

  // for php
  @define('PHP_USE_GZIP', false, true);
  @define('PHP_GZIP_LEVEL', 2, true);

  $schedule_rand = 10;
    // rand for schedulers start, +0..X seconds

  $do_diagnostic = true;
  $log_file = '/var/log/rutorrent.log';
    // path to log file (comment or leave blank to disable logging)

  $saveUploadedTorrents = true;
    // Save uploaded torrents to profile/torrents directory or not
  $overwriteUploadedTorrents = false;
    // Overwrite existing uploaded torrents in profile/torrents directory
    // or make unique name

  $topDirectory = '/'; // Upper available directory. Absolute path with trail slash.
  $forbidUserSettings = false;

  $scgi_port = 5000;
  $scgi_host = "127.0.0.1";

  $XMLRPCMountPoint = "/RPC2"; // DO NOT DELETE THIS LINE!!! DO NOT COMMENT THIS LINE!!!

  // Something like /usr/bin/php. If empty, will be found in PATH.
  $pathToExternals = array(
    "php"   => '/usr/local/bin/php',
    "curl"  => '/usr/bin/curl',
    "gzip"  => '/bin/gzip',
    "id"  => '/usr/bin/id',
    "stat"  => '/bin/stat',
  );

  // list of local interfaces
  $localhosts = array(
    "127.0.0.1",
    "localhost",
  );

  $profilePath = '/config'; // Path to user profiles
    // Mask for files and directory creation in user profiles.
    // Both Webserver and rtorrent users must have read-write access to it.
    // For example, if Webserver and rtorrent users are in the same group
    // then the value may be 0770.
  $profileMask = 0777;

  $tempDirectory = '/tmp/';
    // Temp directory. Absolute path with trail slash.
    // If null, then autodetect will be used.

  $canUseXSendFile = true;
    // Use X-Sendfile feature if it exist

  $locale = "UTF8";
