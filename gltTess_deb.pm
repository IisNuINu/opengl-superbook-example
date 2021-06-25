package gltTess;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltNewTess gltDeleteTess gltTessCallback_s gltTessCallback_c gltTessBeginPolygon gltTessEndPolygon
    gltTessBeginContour  gltTessEndContour gltTessVertex
);

%EXPORT_TAGS = ('all' => \@EXPORT_OK);

use OpenGL qw/ :all/;
use Data::Dumper;
use gltCommon qw/GL_PI/;
use FFI;
use gltExtGLU;
use gltExt;

our ($gluNewTess, $gluDeleteTess, $gluTessCallback, $gluTessBeginPolygon_d, $gluTessBeginPolygon_v, $gluTessEndPolygon,
    $gluTessBeginContour,  $gluTessEndContour, $gltTessVertex);

sub gltNewTess {
    print "run gltNewTess: ".Dumper(\@_)."\n";

    if(!defined($gluNewTess)) {
	    #GLAPI GLUtesselator* GLAPIENTRY gluNewTess (void);
	    #Внимание в связи с тем что FFI не поддерживает возврат значений типа void* используем в качестве
	    #возвращаемого значения unsigned int, т.е работаем с ним как с int переменной
        $gluNewTess = ${gltExtGLU::openGLUlib}->function("gluNewTess", "sI");
    }
    my $p = &$gluNewTess();
    print "pTess: '$p'\n";
    return $p;
}

sub gltDeleteTess {
    print "run gltDeleteTess: ".Dumper(\@_)."\n";
    my $p = shift;
    if(!defined($gluDeleteTess)) {
        $gluDeleteTess = ${gltExtGLU::openGLUlib}->function("gluDeleteTess", "svI");;
    }
    
    &$gluDeleteTess($p);
}

sub gltTessCallback {
    my ($pTess, $wich, $callback, $vars_shablon) = @_;
    my $cb;
    print "run gltTessCallback: ".Dumper(\@_)."\n";

    if(!defined($gluTessCallback)) {
	#void GLAPIENTRY gluTessCallback (GLUtesselator* tess, GLenum which, _GLUfuncptr CallBackFunc);
        $gluTessCallback = ${gltExtGLU::openGLUlib}->function("gluTessCallback", "svIII");
    }

    if(ref(\$callback) eq 'SCALAR') {	#Вызов с текстовой переменной(имя функции опенгл, попробуем найти ее.
        print "refer call with scalarvar: '$callback'\n";
        $cb = gltExt::gltExtGLgetaddress($callback);
        if(defined($cb)) {
	    print "Function '$callback' has address: '$cb'\n";
	    &$gluTessCallback($pTess, $wich, $cb);
	} else {
    	    print "Sorry! not find callback function: '$callback'\n";
	}
    } elsif(ref($callback) eq 'CODE') {	#Вызов с указателем на перловую функцию, создадим callback
	print "make callback: $vars_shablon, $callback\n";
	$cb = FFI::callback($vars_shablon, $callback);
	print "gluTessCallback($pTess, $wich, ".$cb->addr()."\n";
	print "cb: ".Dumper($cb)."\n";
	&$gluTessCallback($pTess, $wich, $cb->addr());
    } else {
        print "Sorry unknown type callback function\n";
    	return;
    }
}

    #Данная функция принимает в качестве каллбек имя функции OpenGL
sub gltTessCallback_s {
    my ($pTess, $wich, $callback, $vars_shablon) = @_;
    my $cb;
    print "run gltTessCallback_s: ".Dumper(\@_)."\n";

    if(!defined($gluTessCallback)) {
	#void GLAPIENTRY gluTessCallback (GLUtesselator* tess, GLenum which, _GLUfuncptr CallBackFunc);
        $gluTessCallback = ${gltExtGLU::openGLUlib}->function("gluTessCallback", "svIII");
    }

    if(ref(\$callback) eq 'SCALAR') {	#Вызов с текстовой переменной(имя функции опенгл, попробуем найти ее.
        print "refer call with scalarvar: '$callback'\n";
        $cb = gltExt::gltExtGLgetaddress($callback);
        if(defined($cb)) {
	    print "Function '$callback' has address: '$cb'\n";
	    &$gluTessCallback($pTess, $wich, $cb);
	} else {
    	    print "Sorry! not find callback function: '$callback'\n";
	}
    } else {
        print "Sorry unknown type callback function\n";
    	return;
    }
}


    #Данная фукнция принимает в качестве параметра CallBack
sub gltTessCallback_c {
    my ($pTess, $wich, $cb) = @_;
    print "run gltTessCallback_c: ".Dumper(\@_)."\n";

    if(!defined($gluTessCallback)) {
	#void GLAPIENTRY gluTessCallback (GLUtesselator* tess, GLenum which, _GLUfuncptr CallBackFunc);
        $gluTessCallback = ${gltExtGLU::openGLUlib}->function("gluTessCallback", "svIII");
    }

    &$gluTessCallback($pTess, $wich, $cb->addr());
}

sub gltTessBeginPolygon {
    my ($pTess, $data) = @_;
    print "run gltTessBeginPolygon: ".Dumper(\@_)."\n";
    if(!defined($gluTessBeginPolygon_d)) {
	#GLAPI void GLAPIENTRY gluTessBeginPolygon (GLUtesselator* tess, GLvoid* data);
	    #Вызов с данными
        $gluTessBeginPolygon_d = ${gltExtGLU::openGLUlib}->function("gluTessBeginPolygon", "svIp");
    	    #Вызов без данных
        $gluTessBeginPolygon_v = ${gltExtGLU::openGLUlib}->function("gluTessBeginPolygon", "svII");
    }
    if(defined($data)) {
	&$gluTessBeginPolygon_d($pTess, $data);
    } else {
	&$gluTessBeginPolygon_v($pTess, 0);
    }
}

sub gltTessEndPolygon {
    my ($pTess) = @_;
    print "run gltTessEndPolygon: ".Dumper(\@_)."\n";
    
    if(!defined($gluTessEndPolygon)) {
	#GLAPI void GLAPIENTRY gluTessEndPolygon (GLUtesselator* tess);
        $gluTessEndPolygon = ${gltExtGLU::openGLUlib}->function("gluTessEndPolygon", "svI");
    }
    &$gluTessEndPolygon($pTess);
}


sub gltTessBeginContour {
    my ($pTess) = @_;
    print "run gltTessBeginContour: ".Dumper(\@_)."\n";
    if(!defined($gluTessBeginContour)) {
	#GLAPI void GLAPIENTRY gluTessBeginContour (GLUtesselator* tess);
        $gluTessBeginContour = ${gltExtGLU::openGLUlib}->function("gluTessBeginContour", "svI");
    }
    &$gluTessBeginContour($pTess);
}


sub gltTessEndContour {
    my ($pTess) = @_;
    print "run gltTessEndContour: ".Dumper(\@_)."\n";
    if(!defined($gluTessEndContour)) {
	#GLAPI void GLAPIENTRY gluTessEndContour (GLUtesselator* tess);
        $gluTessEndContour = ${gltExtGLU::openGLUlib}->function("gluTessEndContour", "svI");
    }
    &$gluTessEndContour($pTess);
}

sub gltTessVertex {
	#В функцию должны передаваться именно ссылки на данные, иначе после этого все данные будут иметь один и тот же адрес
    my ($pTess, $loc_ptr, $data_ptr) = @_;
    print "run gltTessVertex: ".Dumper(\@_)."\n";
    if(!defined($gluTessVertex)) {
	#GLAPI void GLAPIENTRY gluTessVertex (GLUtesselator* tess, GLdouble *location, GLvoid* data);
        $gluTessVertex = ${gltExtGLU::openGLUlib}->function("gluTessVertex", "svIII");
    }
    #my ($l1, $l2, $l3) = unpack("d3", unpack('P', $loc_ptr));
    #my ($d1, $d2, $d3) = unpack("d3", unpack('P', $data_ptr));
    #print "run gltTessVertex, loc[$loc_ptr]($l1, $l2, $l3), data[$data_ptr]($d1, $d2, $d3): \n";
    print "run gltTessVertex, loc[$loc_ptr], data[$data_ptr]\n";
    &$gluTessVertex($pTess, $loc_ptr, $data_ptr);
}


1;
