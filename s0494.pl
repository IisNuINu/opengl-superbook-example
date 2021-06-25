#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use lib ".";
use gltCommon qw/GL_PI/;

use constant SCREEN_X =>  800;
use constant SCREEN_Y =>  600;

my ($xRot, $yRot) = (330.0, 0.0);

my @ctrlPoint = (
    [ 				#u = 0
	[-6.0,-6.0, 0.0],	#v = 0
	[-6.0,-2.0, 0.0],	#v = 1
	[-6.0, 2.0, 0.0],	#v = 2
	[-6.0, 6.0, 0.0]	#v = 3
    ],		
    [ 				#u = 1
	[-2.0,-6.0, 0.0],	#v = 0
	[-2.0,-2.0, 8.0],	#v = 1
	[-2.0, 2.0, 8.0],	#v = 2
	[-2.0, 6.0, 0.0]	#v = 3
    ],		
    [ 				#u = 2
	[ 2.0,-6.0, 0.0],	#v = 0
	[ 2.0,-2.0, 8.0],	#v = 1
	[ 2.0, 2.0, 8.0],	#v = 2
	[ 2.0, 6.0, 0.0]	#v = 3
    ],		
    [ 				#u = 3
	[ 6.0,-6.0, 0.0],	#v = 0
	[ 6.0,-2.0, 0.0],	#v = 1
	[ 6.0, 2.0, 0.0],	#v = 2
	[ 6.0, 6.0, 0.0]	#v = 3
    ]	
);

my @knots = (0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0);

my $pNurb;

sub DrawPoints {
    glPointSize(5.0);
    glColor3ub(255, 0, 0);
    glBegin(GL_POINTS);
    foreach my $plane (@ctrlPoint) {
	#print "P".Dumper($p)."\n";
	foreach my $p (@$plane) {
    	    #glVertex3fv_p($p->[0], $p->[1], $p->[3]);
    	    glVertex3fv_p(@$p);
	}
    }
    glEnd();
}

sub RenderScene {
    glColor3ub(0, 0, 220);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    my ($start, $end, $size_point, $size_slice) = (0, 10, 3, 4);
    
	#// Save the modelview matrix stack
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();

	    #// Rotate the mesh around to make it easier to see
        glRotatef($xRot, 1.0, 0.0, 0.0);
        glRotatef($yRot, 0.0, 1.0, 0.0);

	print "pNurbs: ".Dumper($pNurb)."\n";
	gluBeginSurface($pNurb);
	
	my @tmp = map { map {@$_ } @$_ } @ctrlPoint;
	#print "tmp:\n".Dumper(\@tmp)."\n";
	my $numFloatVar = ($#ctrlPoint+1) *$size_point*$size_slice;
	#Данная функция  gluNurbsSurface_c на работает с упакованным данными
	#my $t = pack("f$numFloatVar", @tmp);
	# поэтому надо применять специальный массив
	my $t = OpenGL::Array->new_list(GL_FLOAT,@tmp); 
	
	my $l_knots = $#knots+1;
	#my $cknots = pack("f$l_knots", @knots);
	my $cknots = OpenGL::Array->new_list(GL_FLOAT,@knots);
	    # Evaluate the surface
	gluNurbsSurface_c($pNurb,	# pointer to NURBS renderer
    	    $l_knots, $cknots->ptr(),          # No. of knots and knot array u direction
    	    $l_knots, $cknots->ptr(),          # No. of knots and knot array v direction
    	    $size_slice*$size_point,    # Distance between control points in u dir.
    	    $size_point,                # Distance between control points in v dir.
    	    $t->ptr(),				# Control points
    	    4, 4,                       # u and v order of surface
    	    GL_MAP2_VERTEX_3);          # Type of surface

	    # Done with surface
	gluEndSurface($pNurb);
	print "pNurbs: ".Dumper($pNurb)."\n";
	
	    #Рисуем контрольные точки
	DrawPoints();

    glPopMatrix();

    glutSwapBuffers();
}

sub NurbsErrorHandler {
    my  $nErrorCode = shift;
    print "NURBS Error occured: ".gluErrorString($nErrorCode)."\n";
}

sub SetupRC {
    my @whiteLight = (0.7, 0.7, 0.7, 1.0);
    my @specular   = (0.7, 0.7, 0.7, 1.0);
    my @shine      = (100.0);

	#White background
    glClearColor(1.0, 1.0, 1.0, 1.0);

    glEnable(GL_DEPTH_TEST);    #Hidden surface removal

        #// Lighting stuff
    glEnable(GL_LIGHTING);      # Enable lighting
    glEnable(GL_LIGHT0);

    glEnable(GL_COLOR_MATERIAL); # Enable Material color tracking
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
    glMaterialfv_p(GL_FRONT, GL_SPECULAR,  @specular);
    glMaterialfv_p(GL_FRONT, GL_SHININESS, @shine);
    
	# Automatically generate normals for evaluated surfaces
    glEnable(GL_AUTO_NORMAL);
    
	#// Setup the Nurbs object
    $pNurb = gluNewNurbsRenderer();
    #print "pNurbs: ".Dumper($pNurb)."\n";
	#// Install error handler to notify user of NURBS errors
    #gluNurbsCallback($pNurb, GLU_ERROR, \&NurbsErrorHandler);

    OpenGL::gluNurbsProperty($pNurb, GLU_SAMPLING_TOLERANCE, 25.0);
	# Uncomment the next line and comment the one following to produce a
	# wire frame mesh.
	#gluNurbsProperty(pNurb, GLU_DISPLAY_MODE, GLU_OUTLINE_POLYGON);
    OpenGL::gluNurbsProperty($pNurb, GLU_DISPLAY_MODE, GLU_FILL);
}


sub ChangeSize {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 40.0;
    my @lightPos = ( -50.0, 50.0, 100.0, 1.0 );

    if($h == 0) {    #предотвращает деление на 0
        $h = 1;
    }

    glViewport(0, 0, $w, $h);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    $fAspect = $w/$h;
    gluPerspective(45.0, $fAspect, 1.0, $nRange);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glTranslatef(0.0, 0.0, -25.0);
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


eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(SCREEN_X, SCREEN_Y);
glutCreateWindow("NURBS Surface");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
