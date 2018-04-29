#!/usr/bin/env perl6

use v6.c;

use Test;

use Igo;

my $obj;

my $dist-path = $*PROGRAM.parent(2);

lives-ok { $obj = Igo.new(directory => $dist-path) }, "make new object";

ok $obj.meta-path.f, "got the right meta path";

nok $obj.layout-path.e, "layout doesn't exist";

isa-ok $obj.layout, "Oyatul::Layout";

ok $obj.layout-path.e, "and now the layout file does exist";

for $obj.distribution-files -> $file {
    ok $file.f, "$file exists";
}


LEAVE {
    $obj.layout-path.unlink;
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
