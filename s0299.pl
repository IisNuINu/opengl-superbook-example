#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use lib ".";
use gltCommon qw/GL_PI gltDegToRad/;
use gltVector3;
use gltMatrix;
use gltTorus qw/gltDrawTorus/;
use gltFrame;

my ($xRot, $yRot) = (0.0, 0.0);
my $yRotTor = 0.0;

my $NUM_SPHERES=20;
my @spheres;

my ($windowWidth, $windowHeight);
my $frameCamera;

    #// Light and material Data
my @lightPos       = ( -100.0, 100.0, 50.0, 1.0 );
my @lightPosMirror = ( -100.0, -100.0, 50.0, 1.0 );
my @noLight = ( 0.0, 0.0, 0.0, 0.0 );
my @lowLight = ( 0.25, 0.25, 0.25, 1.0 );
my @brightLight = ( 1.0, 1.0, 1.0, 1.0 );


sub SetupRC {
    glClearColor($lowLight[0], $lowLight[1], $lowLight[2], $lowLight[3] );
	#// Cull backs of polygons
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);

	#// Setup light parameters
    glLightModelfv_p(GL_LIGHT_MODEL_AMBIENT, @noLight);
    glLightfv_p(GL_LIGHT0, GL_AMBIENT, @lowLight);
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE, @brightLight);
    glLightfv_p(GL_LIGHT0, GL_SPECULAR,@brightLight);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);

	#// Mostly use material tracking
    glEnable(GL_COLOR_MATERIAL);
    glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
    glMateriali(GL_FRONT, GL_SHININESS, 128);

    $frameCamera = gltFrame->new();
}


sub ChangeSize {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 50.0;
    if($h == 0) {    #предотвращает деление на 0
	$h = 1;
    }
    glViewport(0, 0, $w, $h);
    $fAspect = $w/$h;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    gluPerspective(35.0, $fAspect, 1.0, $nRange);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub DrawGeometry {
    my $delta = shift;

    glPushMatrix();
	glColor3f(1.0, 0.0, 0.0);	
	glRotatef(-($yRotTor+$delta)*2.0, 0.0, 1.0, 0.0);
	glTranslatef(1.0, 0.0, 0.0);
	glutSolidSphere(0.1, 17, 9);
    glPopMatrix();
}

sub RenderScene {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    my $fPasses = 3;    
    my $delta   = 0.0;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glPushMatrix();
	$frameCamera->ApplyCameraTransform();

	#print "Draw Ground\n";
	DrawGround();
	#print "After Draw Ground\n";
	for(my $fPass = 0; $fPass < $fPasses; $fPass += 1) {
	    if($fPass != 0) {
		#glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	    }
	    #print "Draw Geometry '$fPass'\n";
	    DrawGeometry($delta);
	    #print "After Draw Geometry\n";
	    if($fPass == 0) {
	    	glAccum(GL_LOAD, 1.0);
	    } else {
	    	glAccum(GL_ACCUM, 0.5*(1.0/$fPass));
	    }
	    $delta += 0.75;
	}
    glPopMatrix();
	# // copy accumulation buffer to color buffer
    #glAccum(GL_RETURN, 1.0);
    glutSwapBuffers();
}

sub TimerFunc {
    my $val= shift;

    $yRotTor += 1.0;
    if($yRotTor > 360.0) {
	$yRotTor -= 360.0;
    }
    
    glutPostRedisplay();
    glutTimerFunc(33, \&TimerFunc, 1);
}


sub DrawAxis {
        #Нарисуем 3 оси Х, У, Z
    glBegin(GL_LINES);
        glVertex3f(100.0, 0.0, 0.0);
        glVertex3f(-100.0, 0.0, 0.0);
    glEnd();
    glBegin(GL_LINES);
        glVertex3f(0.0,  100.0, 0.0);
        glVertex3f(0.0, -100.0, 0.0);
    glEnd();
    glBegin(GL_LINES);
        glVertex3f(0.0,  0.0,  100.0);
        glVertex3f(0.0,  0.0, -100.0);
    glEnd();
}

sub DrawGround {
    my $fExtent = 20.0;
    my $fStep   = 0.5;
    my $y       = -0.4;
    my $fColor;
    my ($iStrip, $iRun);
    my $iBounce = 0;
    
    glShadeModel(GL_FLAT);
    for($iStrip = -$fExtent; $iStrip <= $fExtent; $iStrip += $fStep) {
	glBegin(GL_TRIANGLE_STRIP);
	    #glNormal3f(0.0, 1.0, 0.0);	#All Point UP
	    for($iRun = $fExtent; $iRun >= -$fExtent; $iRun -= $fStep) {
		if(($iBounce%2) == 0) {
		    $fColor = 1.0;
		} else {
		    $fColor = 0.0;
		}
		glColor4f($fColor, $fColor, $fColor, 0.5);
		glVertex3f($iStrip,        $y,  $iRun);
		glVertex3f($iStrip+$fStep, $y,  $iRun);
		$iBounce++;
	    }
	glEnd();
    }
    glShadeModel(GL_SMOOTH);
}


sub SpecialKeys {
    my ($key, $x, $y) = @_;
    if($key == GLUT_KEY_UP) {
	#print "forward 0.1\n";
	$frameCamera->MoveForward(0.1);
    } elsif($key == GLUT_KEY_DOWN) {
	#print "forward -0.1\n";
	$frameCamera->MoveForward(-0.1);
    } elsif($key == GLUT_KEY_LEFT) {
	#print "Rotate Y 0.1\n";
	$frameCamera->RotateLocalY(0.1);
    } elsif($key == GLUT_KEY_RIGHT) {
	#print "Rotate Y -0.1\n";
	$frameCamera->RotateLocalY(-0.1);
    }
    #$frameCamera->print('Camera');
    
    glutPostRedisplay();
}
sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b") {
	exit(0);
    }
    if($key eq 'T') {
	$frameCamera->clear();
    } elsif( $key eq 'Q') {
	$frameCamera->MoveUp(0.1);
    } elsif( $key eq 'A') {
	$frameCamera->MoveUp(-0.1);
    } elsif( $key eq 'W') {
	$frameCamera->RotateLocalX(-0.1);
    } elsif( $key eq 'S') {
	$frameCamera->RotateLocalX(0.1);
    } elsif( $key eq 'E') {
	$frameCamera->RotateLocalZ(-0.1);
    } elsif( $key eq 'R') {
	$frameCamera->RotateLocalZ(0.1);
    } elsif( $key eq 'D') {
	$frameCamera->MoveRight(0.1);
    } elsif( $key eq 'F') {
	$frameCamera->MoveRight(-0.1);
    }
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
glutCreateWindow("OpenGL SphereWord Demo + Lights and Shadow");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutTimerFunc(33, \&TimerFunc, 1);
glutMainLoop();
