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

my $NUM_SPHERES=50;
my @spheres;

my ($windowWidth, $windowHeight);
my $frameCamera;

#print "FrameCamera: ". Dumper($frameCamera)."\n";

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

sub RenderScene {
    my ($transformationMatrix);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    $frameCamera->ApplyCameraTransform();
	#Рисуем "пол"
    DrawGround();
	#Рисуем статические сферы
    foreach my $s (@spheres) {
	glPushMatrix();
	$s->ApplyActorTransform();
	glutSolidSphere(0.1, 13, 26);
	glPopMatrix();
    }
    
    glTranslatef(0.0, 0.0, -2.5);
	#Рисуем вращающуюся сферу
    glPushMatrix();
	glRotatef(-$yRotTor*2.0, 0.0, 1.0, 0.0);
	glTranslatef(1.0, 0.0, 0.0);
	glutSolidSphere(0.1, 13, 26);
    glPopMatrix();
	#Рисуем ТОР
    glRotatef($yRotTor, 0.0, 1.0, 0.0);
    gltDrawTorus(0.35, 0.15, 40, 20);
    
    #glPopMatrix();
	#увеличиваем угол поворота
    glutSwapBuffers();
}

sub TimerFunc {
    my $val= shift;

    $yRotTor += 0.5;
    if($yRotTor > 360.0) {
	$yRotTor -= 360.0;
    }
    
    glutPostRedisplay();
    glutTimerFunc(33, \&TimerFunc, 1);
}

sub SetupRC {
    #glColor3f(0.0, 1.0, 0.0);
    glClearColor(0.0, 0.0, 0.50, 1.0 );
	# Draw everything as wire frame
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    
    $frameCamera = gltFrame->new();
    for(my $iSphere = 0; $iSphere < $NUM_SPHERES; $iSphere++) {
	my $s = gltFrame->new();
	$s->{vLocation}->[0] = rand(40)-20;
	$s->{vLocation}->[1] =  0.0;
	$s->{vLocation}->[2] = rand(40)-20;
	push @spheres, $s;
    }
}

sub DrawGround {
    my $fExtent = 20.0;
    my $fStep   = 1.0;
    my $y       = -0.4;
    
    glBegin(GL_LINES);
	for(my $iLine = -$fExtent; $iLine <= $fExtent; $iLine += $fStep) {
	    glVertex3f($iLine, $y, $fExtent);
	    glVertex3f($iLine, $y, -$fExtent);

	    glVertex3f( $fExtent, $y, $iLine);
	    glVertex3f(-$fExtent, $y, $iLine);
	}
    glEnd();
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
glutCreateWindow("OpenGL SphereWord Demo");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutTimerFunc(33, \&TimerFunc, 1);
glutMainLoop();
