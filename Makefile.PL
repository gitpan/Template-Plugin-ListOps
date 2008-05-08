
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME             => 'Template::Plugin::ListOps',
	VERSION	         => '1.03',
	($] >= 5.005
	? (ABSTRACT=>'Plugin interface to list operations',
	   AUTHOR  =>'Sullivan Beck (sbeck@cpan.org)')
	: ()),
	'dist' => {COMPRESS=>'gzip',SUFFIX=>'gz'},
	PREREQ_PM => {
		'Template::Plugin'    => '0',
		'Sort::DataTypes'     => '0',
		'Test::More'          => '0',
		'Test::Pod'           => '0',
		'Test::Pod::Coverage' => '0',
	},
);
