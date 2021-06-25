#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use lib ".";
use gltVector3;
my ($xRot, $yRot) = (0.0, 0.0);
my $fElect1 = 0.0;

my ($windowWidth, $windowHeight);

#Освещаемый шар, и фонарь
use constant MODE_FLAT	 	=> 1;
use constant MODE_SMOOTH 	=> 2;
use constant MODE_VERYLOW 	=> 3;
use constant MODE_MEDIUM 	=> 4;
use constant MODE_VERYHIGH	=> 5;

my $iShade = MODE_FLAT;
my $iTess  = MODE_VERYLOW;

my @lightPos = (0.0, 0.0, 75.0, 1.0);
my @specular = (1.0, 1.0, 1.0, 1.0);
my @specref  = (1.0, 1.0, 1.0, 1.0);
my @ambientLight = (0.5, 0.5, 0.5, 1.0);
my @spotDir  = (0.0, 0.0, -1.0);

sub ChangeSizeOrtho {
    my ($w, $h) = @_;
    my $aspectRatio;
    my $nRange = 80.0;
    if($h == 0) {    #предотвращает деление на 0
	$h = 1;
    }
    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    $aspectRatio = $w/$h;
    if($w <= $h) {
	$windowWidth  = $nRange;
	$windowHeight = $nRange/$aspectRatio;
	glOrtho(-$nRange, $nRange, -$windowHeight, $windowHeight, -$nRange, $nRange);
    } else {
	$windowWidth  = $nRange*$aspectRatio;
	$windowHeight = $nRange;
	glOrtho(-$windowWidth, $windowWidth, -$nRange, $nRange, -$nRange, $nRange);
    }
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub ChangeSizePerspect {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 500.0;

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
	#сместим начало координат построения модели
    glTranslatef(0.0, 0.0, -250.0);

}

sub DrawFlashlight {
    my ($pLightPos, $pSpotDir, $x_rot, $y_rot) = @_;
    glPushMatrix();
	glRotatef($x_rot, 1.0, 0.0, 0.0);
	glRotatef($y_rot, 0.0, 1.0, 0.0);
    
        glLightfv_p(GL_LIGHT0, GL_POSITION, @$pLightPos);
        glLightfv_p(GL_LIGHT0, GL_SPOT_DIRECTION, @$pSpotDir);
	
    	    #// Draw a red cone to enclose the light source
        glColor3ub(255, 0, 0);

    	    #// Translate origin to move the cone out to where the light
    	    #// is positioned.
        glTranslatef($pLightPos->[0], $pLightPos->[1], $pLightPos->[2]);
        glutSolidCone(4.0, 6.0, 15, 15);

    	    #// Draw a smaller displaced sphere to denote the light bulb
    	    #// Save the lighting state variables
        glPushAttrib(GL_LIGHTING_BIT);

        	#// Turn off lighting and specify a bright yellow sphere
            glDisable(GL_LIGHTING);
            glColor3ub(255, 255, 0);
            glutSolidSphere(3.0, 15, 15);

    	    #// Restore lighting state variables
        glPopAttrib();
	
    glPopMatrix();
}

sub RenderScene {
    if($iShade == MODE_FLAT) {
	glShadeModel(GL_FLAT);
    } else {
	glShadeModel(GL_SMOOTH);
    }

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    #glPushMatrix();
	#Рисуем фонарь
    DrawFlashlight(\@lightPos, \@spotDir, $xRot, $yRot);
    	#Рисуем синюю сферу
	#// Set material color and draw a sphere in the middle
    glColor3ub(0, 0, 255);
    if($iTess == MODE_VERYLOW) {
        glutSolidSphere(30.0, 7, 7);
    } elsif( $iTess == MODE_MEDIUM) {
        glutSolidSphere(30.0, 15, 15);
    } else {	#//  iTess = MODE_MEDIUM;
        glutSolidSphere(30.0, 50, 50);
    }
    #glPopMatrix();
    

    glutSwapBuffers();
}


sub SetupRC {

    glEnable(GL_DEPTH_TEST);	#Hidden surface removal
    glEnable(GL_CULL_FACE);	#Do not calculate inside of jet
    glFrontFace(GL_CCW);	#Counter clock-wise polygons face out

	#// Lighting stuff
    glEnable(GL_LIGHTING);	# Enable lighting
	#// Supply a slight ambient light so the objects can be seen
    glLightModelfv_p(GL_LIGHT_MODEL_AMBIENT, @ambientLight);

	#// Set light model to use ambient light specified by ambientLight
    glLightfv_p(GL_LIGHT0, GL_AMBIENT,  @ambientLight );    
    glLightfv_p(GL_LIGHT0, GL_SPECULAR, @specular );    
    glLightfv_p(GL_LIGHT0, GL_POSITION, @lightPos );    
	#// Specific spot effects
	#// Cut off angle is 60 degrees
    glLightf(GL_LIGHT0,GL_SPOT_CUTOFF,50.0);

    glEnable(GL_LIGHT0);

    glEnable(GL_COLOR_MATERIAL); # Enable Material color tracking

	# Front material ambient and diffuse colors track glColor
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
	#с этого момента все материалы получают способность отражать блики
    glMaterialfv_p(GL_FRONT, GL_SPECULAR, @specref);
    glMateriali(GL_FRONT, GL_SHININESS, 128);

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

sub ProcessMenu {
    my $value = shift;
    if($value == 1) {
        $iShade = MODE_FLAT;
    } elsif ($value == 2) {
        $iShade = MODE_SMOOTH;
    } elsif ($value == 3) {
        $iTess  = MODE_VERYLOW;
    } elsif ($value == 4) {
        $iTess  = MODE_MEDIUM;
    } elsif ($value == 5) {
        $iTess  = MODE_VERYHIGH;
    }
    glutPostRedisplay();
}


eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
glutCreateWindow("Spot");
    #Создание меню
glutCreateMenu(\&ProcessMenu);
glutAddMenuEntry("Flat Shading", 1);
glutAddMenuEntry("Smooth Shading", 2);
glutAddMenuEntry("VL Tess", 3);
glutAddMenuEntry("MD Tess", 4);
glutAddMenuEntry("VH Tess", 5);
glutAttachMenu(GLUT_RIGHT_BUTTON);

glutReshapeFunc(\&ChangeSizePerspect);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
