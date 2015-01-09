use strict;
use warnings;
use Selenium::Remote::Driver;

my $driver = Selenium::Remote::Driver->new('browser_name' =>'phantomjs');
$driver->debug_on();
$driver->get('http://www.google.com');
warn $driver->get_title();
$driver->quit();

