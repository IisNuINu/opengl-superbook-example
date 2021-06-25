package gltExtGLU;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltExtGLUgetaddress);

use OpenGL qw/:all/;
use OpenGL::Image;
use Data::Dumper;
use FFI::Library;

BEGIN {
    our $openGLUlib = FFI::Library->new("-lGLU");
    if(!defined($openGLUlib)) {
        die ("gltExtGLU: Error load library GLU!\n");
    } else {
	print "Load libGLU for ext function\n";
    }
}

sub gltExtGLUgetaddress {
    if ($^O eq 'MSWin32') {
        Win32::GetProcAddress($$openGLUlib, $_[0]);
    }
    else {
        DynaLoader::dl_find_symbol($$openGLUlib, $_[0]);
    }
}

sub unload {
    if ($^O eq 'MSWin32') {
        Win32::FreeLibrary($_[0]);
    }
    else {
        DynaLoader::dl_free_file($_[0])
            if defined (&DynaLoader::dl_free_file);
    }
}


END {
    unload($openGLUlib);
}


1;
