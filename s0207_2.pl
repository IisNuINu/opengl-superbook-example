#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
#use constant GL_PI =>  3.1415;
use lib ".";
use gltCommon qw/GL_PI gltDegToRad/;
use gltVector3;
use gltMatrix;
use gltTorus qw/gltDrawTorus/;

my ($xRot, $yRot) = (0.0, 0.0);
my $yRotTor = 0.0;

my ($windowWidth, $windowHeight);


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
    $transformationMatrix = gltMatrix->new();
    $transformationMatrix->MakeRotation(gltDegToRad($yRotTor), 0.0, 1.0, 0.0);    
    $transformationMatrix->[12] = 0.0;
    $transformationMatrix->[13] = 0.0;
    $transformationMatrix->[14] = -2.5;
    glLoadMatrixf_p(@$transformationMatrix);
    #gltDrawTorus(0.35, 0.15, 20, 10);
    gltDrawTorus(0.35, 0.15, 40, 20);
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
    
    $xRot = 0.0   if($xRot > 356.0);
    $xRot = 355.0 if($xRot < -1.0);
    $yRot = 0.0   if($yRot > 356.0);
    $yRot = 355.0 if($yRot < -1.0);
    
    glutPostRedisplay();
}
sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b" or $key eq 'Q') {
	exit(0);
    }
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
glutCreateWindow("Rotation Tor");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutTimerFunc(33, \&TimerFunc, 1);
glutMainLoop();
