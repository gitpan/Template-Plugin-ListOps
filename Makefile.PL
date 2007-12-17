use ExtUtils::MakeMaker;
WriteMakefile(
   NAME => "Template::Plugin::ListOps",
   VERSION_FROM => "ListOps.pm",
   ($] >= 5.005
       ? (ABSTRACT   => 'Plugin interface to list operations',
          AUTHOR     => 'Sullivan Beck (sbeck@cpan.org)')
       : ()),
   'dist' => {COMPRESS=>'gzip',SUFFIX=>'gz'},
   PREREQ_PM => {
                 Template                => 0,
                 Template::Plugin        => 0,
                 IO::File                => 0,
                 Date::Manip             => 0,
                 Sort::DataTypes         => 0,
                },
);
