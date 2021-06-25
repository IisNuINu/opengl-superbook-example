package gltTess;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltNewTess gltDeleteTess gltTessCallback gltTessBeginPolygon gltTessEndPolygon
    gltTessBeginContour  gltTessEndContour gltTessVertex gltTessProperty
);

%EXPORT_TAGS = ('all' => \@EXPORT_OK);

use OpenGL qw/ :all/;
use Data::Dumper;
use gltCommon qw/GL_PI/;
use FFI;
use gltExtGLU;
use gltExt;

use constant GLU_TESS_BEGIN =>  100100;
use constant GLU_TESS_END   =>  100102;
use constant GLU_TESS_VERTEX=>  100101;
use constant GLU_TESS_ERROR =>  100103;
use constant GLU_TESS_WINDING_RULE =>  100140;
use constant GLU_TESS_WINDING_ODD  =>  100130;


our ($gluNewTess, $gluDeleteTess, $gluTessCallback, 
    $gluTessBeginPolygon_d, $gluTessBeginPolygon_v, $gluTessEndPolygon,
    $gluTessBeginContour,  $gluTessEndContour, $gluTessVertex, $gluTessProperty);

#хеш созданных callback функций, время жизни его = время жизни всей программы
#иначе созданные в фукнции gltTessCallback объекты уничтожаются и при приходе callback вызова
#умирает и вся программа
my %hash_callback;

sub gltNewTess {
    if(!defined($gluNewTess)) {
	    #GLAPI GLUtesselator* GLAPIENTRY gluNewTess (void);
	    #Внимание в связи с тем что FFI не поддерживает возврат значений типа void* используем в качестве
	    #возвращаемого значения unsigned int, т.е работаем с ним как с int переменной
        $gluNewTess = ${gltExtGLU::openGLUlib}->function("gluNewTess", "sI");
    }
    my $p = &$gluNewTess();
    return $p;
}

sub gltDeleteTess {
    my $p = shift;
    if(!defined($gluDeleteTess)) {
        $gluDeleteTess = ${gltExtGLU::openGLUlib}->function("gluDeleteTess", "svI");;
    }
    
    &$gluDeleteTess($p);
}

sub gltTessCallback {
    my ($pTess, $wich, $callback, $vars_shablon) = @_;
    my $cb;

    if(!defined($gluTessCallback)) {
	#void GLAPIENTRY gluTessCallback (GLUtesselator* tess, GLenum which, _GLUfuncptr CallBackFunc);
        $gluTessCallback = ${gltExtGLU::openGLUlib}->function("gluTessCallback", "svIII");
    }

    if(ref(\$callback) eq 'SCALAR') {	#Вызов с текстовой переменной(имя функции опенгл, попробуем найти ее.
        $cb = gltExt::gltExtGLgetaddress($callback);
        if(defined($cb)) {
	    &$gluTessCallback($pTess, $wich, $cb);
	} else {
    	    print "Sorry! not find callback function: '$callback'\n";
	}
    } elsif(ref($callback) eq 'CODE') {	#Вызов с указателем на перловую функцию, создадим callback
	if(!defined($hash_callback{$callback})) {
	    $hash_callback{$callback} = FFI::callback($vars_shablon, $callback);
	}
	&$gluTessCallback($pTess, $wich, $hash_callback{$callback}->addr());
    } else {
        print "Sorry unknown type callback function\n";
    	return;
    }
}


sub gltTessBeginPolygon {
    my ($pTess, $data) = @_;
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
    if(!defined($gluTessEndPolygon)) {
	#GLAPI void GLAPIENTRY gluTessEndPolygon (GLUtesselator* tess);
        $gluTessEndPolygon = ${gltExtGLU::openGLUlib}->function("gluTessEndPolygon", "svI");
    }
    &$gluTessEndPolygon($pTess);
}


sub gltTessBeginContour {
    my ($pTess) = @_;
    if(!defined($gluTessBeginContour)) {
	#GLAPI void GLAPIENTRY gluTessBeginContour (GLUtesselator* tess);
        $gluTessBeginContour = ${gltExtGLU::openGLUlib}->function("gluTessBeginContour", "svI");
    }
    &$gluTessBeginContour($pTess);
}


sub gltTessEndContour {
    my ($pTess) = @_;
    if(!defined($gluTessEndContour)) {
	#GLAPI void GLAPIENTRY gluTessEndContour (GLUtesselator* tess);
        $gluTessEndContour = ${gltExtGLU::openGLUlib}->function("gluTessEndContour", "svI");
    }
    &$gluTessEndContour($pTess);
}

sub gltTessVertex {
	#В функцию должны передаваться именно ссылки на данные, иначе после этого все данные будут иметь один и тот же адрес
    my ($pTess, $loc_ptr, $data_ptr) = @_;
    if(!defined($gluTessVertex)) {
	#GLAPI void GLAPIENTRY gluTessVertex (GLUtesselator* tess, GLdouble *location, GLvoid* data);
        $gluTessVertex = ${gltExtGLU::openGLUlib}->function("gluTessVertex", "svIII");
    }
    &$gluTessVertex($pTess, $loc_ptr, $data_ptr);
}

sub gltTessProperty {
    my ($pTess, $which, $data) = @_;
    if(!defined($gluTessProperty)) {
	#void GLAPIENTRY gluTessProperty (GLUtesselator* tess, GLenum which, GLdouble data);
        $gluTessProperty = ${gltExtGLU::openGLUlib}->function("gluTessProperty", "svIId");
    }
    &$gluTessProperty($pTess, $which, $data);
}


1;
