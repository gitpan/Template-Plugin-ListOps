
use ExtUtils::MakeMaker;

WriteMakefile(
        NAME             => 'Template::Plugin::ListOps',
        VERSION          => '2.00',
        ($] >= 5.005
        ? (ABSTRACT=>'Plugin interface to list operations',
           AUTHOR  =>'Sullivan Beck (sbeck@cpan.org)')
        : ()),
        'dist' => {COMPRESS=>'gzip',SUFFIX=>'gz'},
        PL_FILES  => {},
        PREREQ_PM => {
                'Set::ArrayAlt'       => '0',
                'Sort::DataTypes'     => '0',
                'Template'            => '0',
                'Template::Plugin'    => '0',
                'IO::File'            => '0',
                'Test::More'          => '0',
                'Test::Pod'           => '0',
                'Test::Pod::Coverage' => '0',
        },
);
