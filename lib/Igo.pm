

use Archive::Libarchive;
use CPAN::Uploader::Tiny;
use META6;
use Oyatul;
use XDG::BaseDirectory;

class Igo {
    has IO::Path $.directory is required where *.d;
    has IO::Path $.layout-path;

    method layout-path(--> IO::Path ) {
        $!layout-path //= do {
            $!directory.add: '.layout';
        }
    }

    has IO::Path $.meta-path;

    method meta-path(--> IO::Path ) {
        $!meta-path //= do {
            $!directory.add: 'META6.json';
        }
    }

    has Oyatul::Layout $.layout;

    method layout( --> Oyatul::Layout ) {
        $!layout //= do {
            if $.layout-path.f {
                Oyatul::Layout.from-json(path => $.layout-path);
            }
            else {
                self.create-layout;
            }
        }
    }

    method create-layout(--> Oyatul::Layout ) {
        my $layout = Oyatul::Layout.generate(root => $!directory);
        $.layout-path.spurt: $layout.to-json;
        $layout;
    }

    has META6 $.meta;

    method meta(--> META6) {
        $!meta //= do  {
            META6.new(file => $.meta-path);
        }
    }

    has Str $!distribution-name;

    method distribution-name(--> Str) {
        $!distribution-name //= do {
            $.meta.name.subst('::', '-', :g);
        }
    }

    has Str $!archive-directory;

    method archive-directory(--> Str) {
        $!archive-directory = do {
            "{ $.distribution-name }-{ $.meta.version }";
        }
    }

    has Str $!archive-name;

    method archive-name(--> Str) {
        $!archive-name //= do {
            "{ $.archive-directory }.tar.gz";
        }
    }

    has IO::Path $!archive-path;

    method archive-path(--> IO::Path) {
        $!archive-path = do {
            $!directory.add: $.archive-name;
        }
    }

    method distribution-files() {
        $.layout.all-children.map(*.IO).grep(*.f);
    }

    has Archive::Libarchive $!archive;

    method archive(--> Archive::Libarchive) handles <write-header write-data close> {
        $!archive //= do {
            Archive::Libarchive.new(operation => LibarchiveOverwrite, file => $.archive-path.path, format => 'v7tar', filters => [<gzip>]);
        }
    }

    method create-archive() {
        for $.distribution-files.list -> $file {
            $.write-header($.archive-directory ~ '/' ~ $file.path, size => $file.s, atime => $file.accessed.Int, ctime => $file.changed.Int, mtime => $file.modified.Int, perm => $file.mode);
            $.write-data($file.path);
        }
        $.close;
    }
}

# vim: ft=perl6 sw=4 ts=4 ai
