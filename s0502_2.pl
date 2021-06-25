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

use constant DRAW_LOOPS =>  0;
use constant DRAW_CONCAVE =>  1;
use constant DRAW_COMPLEX =>  0;

use constant GLU_TESS_BEGIN =>  100100;
use constant GLU_TESS_END   =>  100102;
use constant GLU_TESS_VERTEX=>  100101;
use constant GLU_TESS_ERROR =>  100103;


my $iMethod = DRAW_LOOPS;

my @vLake = (
    [ 10.0, -20.0, 0.0],
    [ 15.0, -25.0, 0.0],
    [ 10.0, -30.0, 0.0],
    [  5.0, -25.0, 0.0],
);

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
    print "from callback($x) glVertex3dv($d1, $d2, $d3)\n";
    glVertex3dv_p($d1, $d2, $d3);
}

sub callback_glBegin {
    #print "from callback glBegin\n";
    my $var = shift;
    print "from callback glBegin($var)\n";
    glBegin($var);
}

my $cb_glBegin     = FFI::callback("cvI", \&callback_glBegin);
my $cb_glVertex3dv = FFI::callback("cvI", \&callback_glVertex3dv);
my $cb_tessError   = FFI::callback("cvI", \&tessError);
my (@c_tmp, @c_tmp1); 


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
	#print "pTess: ".hex($pTess)."\n";
        #gltTessCallback($pTess, GLU_TESS_BEGIN, 'glBegin');
        gltTessCallback_c($pTess, GLU_TESS_BEGIN, $cb_glBegin);
        gltTessCallback_s($pTess, GLU_TESS_END,   'glEnd');
        #gltTessCallback($pTess, GLU_TESS_VERTEX, 'glVertex3dv');
    	    #WINGDIAPI void APIENTRY glVertex3dv (const GLdouble *v);
        gltTessCallback_c($pTess, GLU_TESS_VERTEX, $cb_glVertex3dv);
        gltTessCallback_c($pTess, GLU_TESS_ERROR, $cb_tessError);
	#my @tmp = map { @$_ }  @vCoast;
	#my $a_tmp = OpenGL::Array->new_list(GL_FLOAT,@tmp);
	#my (@c_tmp, @c_tmp1); 
	@c_tmp  = ();
	@c_tmp1 = ();
        foreach my $p (@vCoast) {
	    my $t  = pack("d3", @$p);
	    my $t1 = pack("d3", @$p);
    	    push @c_tmp, $t;
    	    push @c_tmp1, $t1;
	}
            # Begin the polygon
        gltTessBeginPolygon($pTess, undef);
        gltTessBeginContour($pTess);
            # Feed in the list of vertices
        print "before cycle gltTessVertex\n";
        foreach my $i (0..$#c_tmp) {
	    #printf("c_tmp[%i] := %24x\n", $i, $c_tmp[$i]);
            gltTessVertex($pTess, unpack('I', pack('P', $c_tmp[$i])), unpack('I', pack('P', $c_tmp1[$i])) );
	}
        print "after cycle gltTessVertex\n";
            # Close contour and polygon
        print "before gltTessEndContour\n";
        gltTessEndContour($pTess);
        print "after gltTessEndContour\n";
        print "before gltTessEndPolygon\n";
        gltTessEndPolygon($pTess);
        print "after gltTessEndPolygon\n";
           # All done with tesselator object
        gltDeleteTess($pTess);
        print "after gltDeleteTess\n";
    } elsif($iMethod == DRAW_COMPLEX) {
    
    }

    glutSwapBuffers();
}

sub SetupRC {
    glClearColor(0.0, 0.0, 1.0, 1.0);
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
