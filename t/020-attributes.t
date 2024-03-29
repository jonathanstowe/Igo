#!/usr/bin/env raku

use v6;

use Test;

use Igo;
use Oyatul;

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

lives-ok {
 $obj.create-archive;
}, "create-archive";

ok $obj.archive-path.f, "archive exists";

%*ENV<XDG_CONFIG_HOME> = "babababaaa"; # just in case we have one

throws-like { $obj.uploader }, X::NoPauseCredentials, "no username/password or config";

$obj = Igo.new(directory => $dist-path, username => "foo", password => "bar");

lives-ok { isa-ok $obj.uploader, "CPAN::Uploader::Tiny" }, "uploader with username and password";

%*ENV<XDG_CONFIG_HOME> = $*PROGRAM.parent.add("config").Str;

$obj = Igo.new(directory => $dist-path);

lives-ok { isa-ok $obj.uploader, "CPAN::Uploader::Tiny" }, "uploader with config";

my Str $duf-layout = q:to/EOLAY/;
{
   "type" : "layout",
   "children" : [
       {
           "type": "file",
           "name" : "zziziz"
       }
   ]
}
EOLAY

$obj = Igo.new(directory => $dist-path, layout => Oyatul::Layout.from-json($duf-layout, root => $dist-path.Str ) );

throws-like { $obj.create-archive }, X::Igo::NoFile, 'throws with missing file in layout';

LEAVE {
    $obj.layout-path.unlink;
    $obj.archive-path.unlink;
}

done-testing;
# vim: expandtab shiftwidth=4 ft=raku
