use inc::Module::Install;
name 'Data-Monad-CondVar';
all_from 'lib/Data/Monad/CondVar.pm';
readme_from 'lib/Data/Monad/CondVar.pm';

requires 'AnyEvent';
requires 'Data::Monad';

tests 't/*.t t/*/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::Requires';
auto_set_repository;
auto_include;

resources
    homepage => 'https://github.com/hiratara/p5-Data-Monad-CondVar',
    bugtracker => 'https://github.com/hiratara/p5-Data-Monad-CondVar/issues';

WriteAll;
