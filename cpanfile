requires 'perl', '5.008001';

requires 'Plack', '0';
requires 'Plack::App::Directory', '0';
requires 'OrePAN2', '0.15';
requires 'Path::Class', '0.32';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Output', '1.02';
    requires 'File::Zglob', '0.11';
};

on 'develop' => sub {
    requires 'Test::Pretty', '0';
};

