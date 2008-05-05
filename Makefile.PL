
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME             => 'Template::Plugin::ListOps',
	VERSION_FROM     => 'ListOps.pm',
	($] >= 5.005
	? (ABSTRACT=>'Plugin interface to list operations',
	   AUTHOR  =>'Sullivan Beck (sbeck@cpan.org)')
	: ()),
	'dist' => {COMPRESS=>'gzip',SUFFIX=>'gz'},
	PREREQ_PM => {
		'Sort::DataTypes'     => '0',
		'Test::More'          => '0',
		'Test::Pod'           => '0',
		'Test::Pod::Coverage' => '0',
	},
);
