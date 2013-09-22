# NAME

Data::Monad::CondVar - The CondVar monad.

# SYNOPSIS

    use Data::Monad::CondVar;

    # The sleep sort
    my @list = (3, 5, 2, 4, 9, 1, 8);
    my @result;
    AnyEvent::CondVar->all(
        map {
            cv_unit($_)->sleep($_ / 1000)
                       ->map(sub { push @result, @_ });
        } @list
    )->recv;

# DESCRIPTION

Data::Monad::CondVar adds monadic operations to AnyEvent::CondVar.

Since this module extends AnyEvent::CondVar directly, you can call monadic
methods anywhere there are CondVars.

This module is marked __EXPERIMENTAL__. API could be changed without any notice.

# METHODS

- $cv = as\_cv($cb->($cv))

    A helper for rewriting functions using callbacks to ones returning CVs.

        my $cv = as_cv { http_get "http://google.ne.jp", $_[0] };
        my ($data, $headers) = $cv->recv;

- $cv = cv\_unit(@vs)
- $cv = cv\_zero()
- $cv = cv\_fail($v)
- $f = cv\_flat\_map\_multi(\\&f, $cv1, $cv2, ...)
- $f = cv\_map\_multi(\\&f, $cv1, $cv2, ...)
- $cv = cv\_sequence($cv1, $cv2, ...)

    These are shorthand of methods which has the same name.

- $cv = call\_cc($f->($cont))

    Calls `$f` with current continuation, `$cont`.
    `$f` must return a CondVar object.
    If you call `$cont` in `$f`, results are sent to `$cv` directly and
    codes left in `$f` will be skipped.

    You can use `call_cc` to escape a deeply nested call structure.

        sub myname {
            my $uc = shift;

          return call_cc {
              my $cont = shift;

                cv_unit("hiratara")->flat_map(sub {
                    return $cont->(@_) unless $uc; # escape from an inner block
                    cv_unit @_;
                })->map(sub { uc $_[0] });
            };
        }

        print myname(0)->recv, "\n"; # hiratara
        print myname(1)->recv, "\n"; # HIRATARA

- unit
- flat\_map

    Overrides methods of [Data::Monad::Base::Monad](http://search.cpan.org/perldoc?Data::Monad::Base::Monad).

- zero

    Overrides methods of [Data::Monad::Base::MonadZero](http://search.cpan.org/perldoc?Data::Monad::Base::MonadZero).
    It uses `fail` method internally.

- $cv = AnyEvent::CondVar->fail($msg)

    Creates the new CondVar object which represents a failed operation.
    You can use `catch` to handle failed operations.

- $cv = AnyEvent::CondVar->any($cv1, $cv2, ...)

    Takes the earliest value from `$cv1`, `$cv2`, ...

- $cv = AnyEvent::CondVar->all($cv1, $cv2, ...)

    Takes all values from `$cv1`, `$cv2`, ...

    This method works completely like `<Data::Monad::Base::Monad-`sequence>>,
    but you may want use this method for better cancellation.

- $cv->cancel

    Cancels computations for this CV. This method just calls the call back
    which is set in the `canceler` field.

    `<$cv-`recv>> may never return from blocking after you call `cancel`.

- $cv->canceler($cb->())
- $code = $cv->canceler

    The accessor of the method to cancel. You should set this field appropriately
    when you create the new CondVar object.

        my $cv = AE::cv;
        my $t = AE::timer $sec, 0, sub {
            $cv->send(@any_results);
            $cv->canceler(undef); # Destroy cyclic refs
        };
        $cv->canceler(sub { undef $t });

- $cv = $cv1->or($cv2)

    If `$cv1` croaks, `or` returns the CondVar object which contains values of
    `$cv2`. Otherwise it returns `$cv1`'s values.

    `or` would be `mplus` on Haskell.

- $cv = $cv1->catch($cb->($@))

    If `$cv1` croaks, `$cb` is called and it returns the new CondVar object
    containing its result. Otherwise `catch` does nothing. `$cb` must return
    a CondVar object.

    You can use this method to handle errors.

        cv_unit(1, 0)
        ->map(sub { $_[0] / $_[1] })
        ->catch(sub {
            my $exception = shift;
            $exception =~ /Illegal division/
                ? cv_unit(0)           # recover from errors
                : cv_fail($exception); # rethrow
        });

- $cv = $cv1->sleep($sec)

    Sleeps `$sec` seconds, and just sends values of `$cv1` to `$cv`.

- $cv = $cv1->timeout($sec)

    If `$cv1` doesn't compute any values within `$sec` seconds,
    `$cv` will be received `undef` and `$cv1` will be canceled.

    Otherwise `$cv` will be received `$cv1`'s results.

- $cv = $cv1->retry($max, \[$pace, \], $f->(@v))

    Continue to call `flat_map($f)` until `$f` returns a normal value which
    doesn't croak.

    `$max` is maximum number of retries, `$pace` is how long it sleeps between
    each retry. The default value of `$pace` is `0`.

# AUTHOR

hiratara <hiratara {at} cpan.org>

# SEE ALSO

[Data::Monad::Base::Monad](http://search.cpan.org/perldoc?Data::Monad::Base::Monad)

[AnyEvent](http://search.cpan.org/perldoc?AnyEvent)

[Promises](http://search.cpan.org/perldoc?Promises)

[Future](http://search.cpan.org/perldoc?Future)

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
