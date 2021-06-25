#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use lib ".";
use gltCommon qw/GL_PI/;
use gltTess qw/ :all/;

use constant SCREEN_X =>  800;
use constant SCREEN_Y =>  600;

my ($xRot, $yRot) = (330.0, 0.0);

my @vCoast = (
    [-70.0, 30.0,  0.0],
    [-50.0, 30.0,  0.0],
    [-50.0, 27.0,  0.0],
    [ -5.0, 27.0,  0.0],
    [  0.0, 20.0,  0.0],
    [  8.0, 10.0,  0.0],
    [ 12.0,  5.0,  0.0],
    [ 10.0,  0.0,  0.0],
    [ 15.0,-10.0,  0.0],
    [ 20.0,-20.0,  0.0],
    [ 20.0,-35.0,  0.0],
    [ 10.0,-40.0,  0.0],
    [  0.0,-30.0,  0.0],
    [ -5.0,-20.0,  0.0],
    [-12.0,-10.0,  0.0],
    [-13.0, -5.0,  0.0],
    [-12.0,  5.0,  0.0],
    [-20.0, 10.0,  0.0],
    [-30.0, 20.0,  0.0],
    [-40.0, 15.0,  0.0],
    [-50.0, 15.0,  0.0],
    [-55.0, 20.0,  0.0],
    [-60.0, 25.0,  0.0],
    [-70.0, 25.0,  0.0]
);
my @vCoast_pack;	#временный массив хранящий скалярный дампы запакованных координат
my @vCoast_ptr;		#временный массив хранящий указатели на области памяти массива @vCoast_pack


use constant DRAW_LOOPS =>  0;
use constant DRAW_CONCAVE =>  1;
use constant DRAW_COMPLEX =>  2;

my $iMethod = DRAW_LOOPS;

my @vLake = (
    [ 10.0, -20.0, 0.0],
    [ 15.0, -25.0, 0.0],
    [ 10.0, -30.0, 0.0],
    [  5.0, -25.0, 0.0],
);
my @vLake_pack;	#временный массив хранящий скалярный дампы запакованных координат
my @vLake_ptr;	#временный массив хранящий указатели на области памяти массива @vLake_pack


my $double_len = length(pack('d', 1.0));
my $double_len3 = $double_len*3;


sub tessError {
    my $error = shift;
    print "TessError: ".gluErrorString($error)."\n"; 
}

sub callback_glVertex3dv {
    my ($x) = @_;
    my $mem_addr = pack('I', $x);
    my $copy_mem = unpack("P$double_len3", $mem_addr);
    my ($d1, $d2, $d3) = unpack("d3", $copy_mem);
    #print "from callback($x) glVertex3dv($d1, $d2, $d3)\n";
    glVertex3dv_p($d1, $d2, $d3);
}

sub callback_glBegin {
    #print "from callback glBegin\n";
    my $var = shift;
    #print "from callback glBegin($var)\n";
    glBegin($var);
}

sub RenderScene {
    glClear(GL_COLOR_BUFFER_BIT );
    if($iMethod == DRAW_LOOPS) {	#Draw line loops
	glColor3f(0.0, 0.0, 0.0);   
	    #Line loop with coastline shape
        glBegin(GL_LINE_LOOP);
        foreach my $p (@vCoast) {
            glVertex3dv_p(@$p);
        }
        glEnd();

    	    #Line loop with shape of interior lake
        glBegin(GL_LINE_LOOP);
        foreach my $p (@vLake) {
            glVertex3dv_p(@$p);
        }
        glEnd();
    } elsif($iMethod == DRAW_CONCAVE) {	#Tesselate concave polygon
	    # Green polygon
        glColor3f(0.0, 1.0, 0.0);
            # Create the tesselator object
        my $pTess = gltNewTess();
        #gltTessCallback($pTess, GLU_TESS_BEGIN, 'glBegin');
        gltTessCallback($pTess, gltTess::GLU_TESS_BEGIN, \&callback_glBegin, "cvI");
        gltTessCallback($pTess, gltTess::GLU_TESS_END,   'glEnd');
    	    #WINGDIAPI void APIENTRY glVertex3dv (const GLdouble *v);
        #gltTessCallback($pTess, GLU_TESS_VERTEX, 'glVertex3dv');
        gltTessCallback($pTess, gltTess::GLU_TESS_VERTEX, \&callback_glVertex3dv, "cvI");
        gltTessCallback($pTess, gltTess::GLU_TESS_ERROR, \&tessError, "cvI");
            # Begin the polygon
        gltTessBeginPolygon($pTess, undef);
        gltTessBeginContour($pTess);
            # Feed in the list of vertices
        foreach my $i (0..$#vCoast_ptr) {
            gltTessVertex($pTess, $vCoast_ptr[$i], $vCoast_ptr[$i] );
	}
            # Close contour and polygon
        gltTessEndContour($pTess);
        gltTessEndPolygon($pTess);
           # All done with tesselator object
        gltDeleteTess($pTess);
    } elsif($iMethod == DRAW_COMPLEX) {
	    # Green polygon
        glColor3f(0.0, 1.0, 0.0);
            # Create the tesselator object
        my $pTess = gltNewTess();
        gltTessCallback($pTess, gltTess::GLU_TESS_BEGIN, 'glBegin');
        #gltTessCallback($pTess, GLU_TESS_BEGIN, \&callback_glBegin, "cvI");
        gltTessCallback($pTess, gltTess::GLU_TESS_END,   'glEnd');
        gltTessCallback($pTess, gltTess::GLU_TESS_VERTEX, 'glVertex3dv');
        #gltTessCallback($pTess, GLU_TESS_VERTEX, \&callback_glVertex3dv, "cvI");
        gltTessCallback($pTess, gltTess::GLU_TESS_ERROR, \&tessError, "cvI");
    	    #Как подсчитать заполненные и открытые области
        gltTessProperty($pTess, gltTess::GLU_TESS_WINDING_RULE, gltTess::GLU_TESS_WINDING_ODD);
	    # Begin the polygon
        gltTessBeginPolygon($pTess, undef);
            # первый контур
        gltTessBeginContour($pTess);
        foreach my $i (0..$#vCoast_ptr) {
            gltTessVertex($pTess, $vCoast_ptr[$i], $vCoast_ptr[$i] );
	}
            # Close contour and polygon
        gltTessEndContour($pTess);
	    #второй контур(озеро)
        gltTessBeginContour($pTess);
        foreach my $i (0..$#vLake_ptr) {
            gltTessVertex($pTess, $vLake_ptr[$i], $vLake_ptr[$i] );
	}
            # Close contour and polygon
        gltTessEndContour($pTess);
        gltTessEndPolygon($pTess);
           # All done with tesselator object
        gltDeleteTess($pTess);
    
    }

    glutSwapBuffers();
}

sub SetupRC {
    glClearColor(0.0, 0.0, 1.0, 1.0);
	#создадим данные для работы с Callback функциями
	#напомню все это очень грязный хак могущий привести к краху перла
    foreach my $p (@vCoast) {
        push @vCoast_pack, pack("d3", @$p);
    }
    foreach my $i (0..$#vCoast_pack) {
        push @vCoast_ptr, unpack('I', pack('P', $vCoast_pack[$i]));
    }

	#пакуем данные об озере
    foreach my $p (@vLake) {
        push @vLake_pack, pack("d3", @$p);
    }
    foreach my $i (0..$#vLake_pack) {
        push @vLake_ptr, unpack('I', pack('P', $vLake_pack[$i]));
    }
}


sub ChangeSize {
    my ($w, $h) = @_;
    my $aspectRatio;
    if($h == 0) {       #предотвращает деление на 0
        $h = 1;
    }
    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
        #псевдокоординаты окна
    gluOrtho2D(-80, 35, -50, 50.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub SpecialKeys {
    my ($key, $x, $y) = @_;
    if($key == GLUT_KEY_UP) {
        $xRot -= 5.0;
    } elsif($key == GLUT_KEY_DOWN) {
        $xRot += 5.0;
    } elsif($key == GLUT_KEY_LEFT) {
        $yRot -= 5.0;
    } elsif($key == GLUT_KEY_RIGHT) {
        $yRot += 5.0;
    }

    $xRot %= 360.0;
    $yRot %= 360.0;

    glutPostRedisplay();
}


sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b") {
	exit(0);
    }
}

sub ProcessMenu {
    my $value = shift;
    $iMethod = $value;
    
    glutPostRedisplay();
}



eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(SCREEN_X, SCREEN_Y);
glutCreateWindow("Tesselated Florida");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
glutCreateMenu(\&ProcessMenu);
glutAddMenuEntry("Line Loops",DRAW_LOOPS);
glutAddMenuEntry("Concave Polygon",DRAW_CONCAVE);
glutAddMenuEntry("Complex Polygon",DRAW_COMPLEX);
glutAttachMenu(GLUT_RIGHT_BUTTON);

SetupRC();
glutMainLoop();
