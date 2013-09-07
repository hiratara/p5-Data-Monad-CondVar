requires 'AnyEvent';
requires 'Data::Monad';
requires 'parent';
requires 'perl', 'v5.12.0';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.59';
    requires 'Test::More', '0.94';
};
