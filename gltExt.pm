package gltExt;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltIsExtSupported gltExtGLgetaddress);

use OpenGL qw/:all/;
use OpenGL::Image;
use Data::Dumper;
use FFI::Library;

BEGIN {
    our $openGLlib = FFI::Library->new("-lGL");
    if(!defined($openGLlib)) {
        die ("gltExt: Error load library OpenGL!\n");
    } else {
	print "Load libGL for ext function\n";
    }
    our $glHistogram;
    our $glGetHistogram;
    our $glColorTable;
    our $glConvolutionFilter2D;
}

END {
    unload($openGLlib);
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


sub gltExtGLgetaddress {
    #print "In gltExtGLgetaddress\n";
    if ($^O eq 'MSWin32') {
        Win32::GetProcAddress($openGLlib, $_[0]);
    }
    else {
	#print "find gltExtGLgetaddress: $_[0] \n";
	#print "Dump openGLlib:".Dumper($$openGLlib)."\n";
        my $ret = DynaLoader::dl_find_symbol($$openGLlib, $_[0]);
	#print "after find gltExtGLgetaddress: $ret\n";
        return $ret;
    }
}


sub gltIsExtSupported {
    my $extension = shift; 
    
    my @extensions = split(/ /, glGetString(GL_EXTENSIONS));
    foreach my $cur_ext (@extensions) {
	print "Check: $cur_ext\n";
	if($cur_ext =~ m/$extension/) {
	    return 1;
	}
    }
    return 0;
}

sub get_func_glHistogram {
	    #void APIENTRY glHistogram (GLenum, GLsizei, GLenum, GLboolean);
    return $openGLlib->function("glHistogram", "svIiIC");
}

sub glHistogram {
    #my ($a, $b, $c, $d) = @_;
    if(!defined($glHistogram)) {
	$glHistogram = get_func_glHistogram();
    }
    &$glHistogram(@_);
}

sub get_func_glGetHistogram {
	    #void APIENTRY glGetHistogram (GLenum, GLboolean, GLenum, GLenum, GLvoid *);
    return $openGLlib->function("glGetHistogram", "svICIIp");
}

sub glGetHistogram {
    my ($name, $a, $b, $c, $size) = @_;
    my (@arr, $i);
    my $all_int_size = $size;
    for($i = 0; $i<$all_int_size; $i++) {#создаем структуру размером size int
	push @arr, 0;
    }
    my $format = "I$all_int_size";
    my $p = pack($format, @arr);
    #my $p = "\0" x $size*4;	#raw buffer for get array, bytes length = size * sizeoff(int)
    if(!defined($glGetHistogram)) {
	$glGetHistogram = get_func_glGetHistogram();
    }
    &$glGetHistogram($name, $a, $b, $c, $p);
    @arr = unpack($format, $p);
    return @arr;
}

#glColorTable(GL_COLOR_TABLE, GL_RGB, $sizeColor, GL_RGB, GL_UNSIGNED_BYTE, \@invertTable);
sub glColorTable {
    my ($name, $a, $size, $b, $c, $p_arr) = @_;
    my $all_int_size = $#$p_arr+1;	#размер передаваемого массива целых
    my $format = "C$all_int_size";
    my $p = pack($format, @$p_arr);
    #print "Arr: ".Dumper($p_arr)."\n";
    #print "Pack: ".Dumper($p)."\n";
    if(!defined($glColorTable)) {
	    #void APIENTRY glColorTable (GLenum, GLenum, GLsizei, GLenum, GLenum, const GLvoid *);
	$glColorTable = $openGLlib->function("glColorTable", "svIIiIIp");;
    }
    &$glColorTable($name, $a, $size, $b, $c, $p);
}

#gltExt::glConvolutionFilter2D(GL_CONVOLUTION_2D, GL_RGB, 3, 3, GL_LUMINANCE, GL_FLOAT, \@mSharpen);
sub glConvolutionFilter2D {
    my ($name, $a, $n1, $n2,  $b, $c, $p_arr) = @_;
    my $all_int_size = $#$p_arr+1;	#размер передаваемого массива целых
    my $format = "f$all_int_size";
    my $p = pack($format, @$p_arr);
    #print "Arr: ".Dumper($p_arr)."\n";
    #print "Pack: ".Dumper($p)."\n";
    if(!defined($glConvolutionFilter2D)) {
	    #void APIENTRY glConvolutionFilter2D (GLenum, GLenum, GLsizei, GLsizei, GLenum, GLenum, const GLvoid *)
	#print "get function ptr glConvolutionFilter2D\n";
	$glConvolutionFilter2D = $openGLlib->function("glConvolutionFilter2D", "svIIiiIIp");;
    }
    #print "function at: '$glConvolutionFilter2D'\n";
    #print "format at: '$format'\n";
    #print "array: '".Dumper(unpack($format,$p))."'\n";

    &$glConvolutionFilter2D($name, $a, $n1, $n2, $b, $c, $p);
}


1;
