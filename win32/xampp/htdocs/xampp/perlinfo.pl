#!"\xampp\perl\bin\perl.exe"

use HTML::Perlinfo;
use CGI qw(header);

$q = new CGI;
print $q->header;

$p = new HTML::Perlinfo;
$p->info_general;
$p->info_variables;
$p->info_modules;
$p->info_license;
