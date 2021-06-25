#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use OpenGL::Image;
use lib ".";
use gltVector3;
use gltTools qw/gltDrawUnitAxes/;
my ($xRot, $yRot) = (0.0, 0.0);

my ($windowWidth, $windowHeight);

#Рисуем Оси

sub ChangeSize {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 40.0;

    if($h == 0) {    #предотвращает деление на 0
        $h = 1;
    }

    glViewport(0, 0, $w, $h);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    $fAspect = $w/$h;
    gluPerspective(35.0, $fAspect, 1.0, $nRange);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub RenderScene {
    my ($x, $y, $z, $angle);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glPushMatrix();
	glTranslatef(0.0, 0.0, -5.0);
	glRotatef($xRot, 1.0, 0.0, 0.0);
	glRotatef($yRot, 0.0, 1.0, 0.0);
	
	#Теперь рисуем сцену
	gltDrawUnitAxes();
    
    glPopMatrix();

    glutSwapBuffers();
}

sub SetupRC {
    my @whiteLight  = (0.05, 0.05, 0.05, 1.0);
    my @sourceLight = (0.25, 0.25, 0.25, 1.0);
    my @lightPos    = (-10.0, 5.0,  5.0, 1.0);
    
    glEnable(GL_DEPTH_TEST);	#Hidden surface removal
    glEnable(GL_CULL_FACE);	#Do not calculate inside of jet
    glFrontFace(GL_CCW);	#Counter clock-wise polygons face out

	#// Lighting stuff
    glEnable(GL_LIGHTING);	# Enable lighting
	#устанавливаем и активизируем источник света 0
    glLightModelfv_p(GL_LIGHT_MODEL_AMBIENT, @whiteLight);
    glLightfv_p(GL_LIGHT0, GL_AMBIENT, @sourceLight );    
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE, @sourceLight );
    glLightfv_p(GL_LIGHT0, GL_POSITION, @lightPos);
    glEnable(GL_LIGHT0);

    glEnable(GL_COLOR_MATERIAL); # Enable Material color tracking

	# Front material ambient and diffuse colors track glColor
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
    glClearColor(0.0, 0.0, 0.0, 1.0);
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
    if($key eq "\x1b" or $key eq 'Q') {
	exit(0);
    }
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
glutCreateWindow("Textured Pyramid");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
