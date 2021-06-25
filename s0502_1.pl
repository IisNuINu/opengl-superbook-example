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

# рисование поверхности nurbs "с вырезом"
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


sub tessError {
    my $error = shift;
    print "TessError: ".gluErrorString($error)."\n"; 
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

        glColor3f(1.0, 1.0, 1.0);
            # Create the tesselator object
        my $pTess = gltNewTess();
	#print "pTess: ".hex($pTess)."\n";
        gltTessCallback($pTess, GLU_TESS_BEGIN, 'glBegin');
        gltTessCallback($pTess, GLU_TESS_END,   'glEnd');
        gltTessCallback($pTess, GLU_TESS_VERTEX, 'glVertex3dv');
        gltTessCallback($pTess, GLU_TESS_ERROR, \&tessError, 'svI');
	#my @tmp = map { @$_ }  @vCoast;
	#my $a_tmp = OpenGL::Array->new_list(GL_FLOAT,@tmp);
	my $c_tmp; 
            # Begin the polygon
        gltTessBeginPolygon($pTess, undef);
        gltTessBeginContour($pTess);
            # Feed in the list of vertices
        foreach my $p (@vCoast) {
    	    $c_tmp = pack("d3", @$p);
            gltTessVertex($pTess, $c_tmp, $c_tmp);
	}
            # Close contour and polygon
        gltTessEndContour($pTess);
        gltTessEndPolygon($pTess);
           # All done with tesselator object
        gltDeleteTess($pTess);
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
