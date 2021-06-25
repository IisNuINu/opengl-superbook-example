#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;

# Анимированный прыгающий квадрат
# как вы уже знаете это инициализация

use constant GL_PI =>  3.1415;
my ($xRot, $yRot) = (0.0, 0.0);
my ($windowWidth, $windowHeight);

sub ChangeSize {
    my ($w, $h) = @_;
    my $aspectRatio;
    my $nRange = 100.0;
    if($h == 0) {	#предотвращает деление на 0
	$h = 1;
    }
    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    $aspectRatio = $w/$h;
    if($w <= $h) {
	$windowWidth  = $nRange;
	$windowHeight = $nRange/$aspectRatio;
	glOrtho(-$nRange, $nRange, -$windowHeight, $windowHeight, $nRange, -$nRange);
    } else {
	$windowWidth  = $nRange*$aspectRatio;
	$windowHeight = $nRange;
	glOrtho(-$windowWidth, $windowWidth, -$nRange, $nRange, $nRange, -$nRange);
    }
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub RenderScene {
    my ($x, $y, $z, $angle);
    glClear(GL_COLOR_BUFFER_BIT);
    glPushMatrix();
    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 1.0, 0.0);
    glBegin(GL_POINTS);
	$z = -50.0;
	for($angle = 0.0; $angle <= 2.0*GL_PI*3.0; $angle += 0.1) {
	    $x = 50.0*sin($angle);
	    $y = 50.0*cos($angle);
	    glVertex3f($x, $y, $z);
	    $z += 0.5;
	}
    glEnd();
    glPopMatrix();
    glutSwapBuffers();
}


sub SetupRC {
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glColor3f(0.0, 1.0, 0.0);
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
glutCreateWindow("Points Example");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
