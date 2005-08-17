use 5.005;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Hey::heyPass',
    'VERSION_FROM'	=> 'heyPass.pm', # finds $VERSION
    'PREREQ_PM'		=> {
        'LWP::UserAgent'=> '2.031',
        'XML::Simple'   => '2.12',
        'Crypt::SSLeay' => '0.51',
    },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (AUTHOR     => 'Dusty Wilson <cpan@dusty.hey.nu>') : ()),
);
