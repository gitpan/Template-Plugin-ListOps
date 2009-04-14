
use Module::Build;

my $build = Module::Build->new(
        license            => 'perl',
        dist_version       => '2.00',
        dist_author        => 'Sullivan Beck <sbeck@cpan.org>',
        module_name        => 'Template::Plugin::ListOps',
        dist_abstract      => 'Plugin interface to list operations',
        requires           => {
                'perl'                => '5.6.0',
                'Set::ArrayAlt'       => '0',
                'Sort::DataTypes'     => '0',
                'Template'            => '0',
                'Template::Plugin'    => '0',
        },
        build_requires     => {
        },
        build_recommends   => {
                'IO::File'            => '0',
                'Test::More'          => '0',
                'Test::Pod'           => '0',
                'Test::Pod::Coverage' => '0',
        },
        sign               => 1,
);

$build->create_build_script;
