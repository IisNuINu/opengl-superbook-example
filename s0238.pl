#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
my ($xRot, $yRot) = (0.0, 0.0);
my $fElect1 = 0.0;

my ($windowWidth, $windowHeight);
my @sizes; # = (0.0, 0.0);        #Допустимые размеры точек ОпенГЛ
my $step;                #минимальный поддерживаемый инкремент размеров точек

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
    my $nRange = 1000.0;
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
    #glMatrixMode(GL_MODELVIEW);
    #glLoadIdentity();
    glPushMatrix();
    	#Транслируем всю сцену в поле зрения наблюдателя
	#Это исходное преобразование наблюдения
	#установим нужный ракурс   
    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 1.0, 0.0);
	#Теперь рисуем сцену
    DrawJet();
    
    glPopMatrix();

    glutSwapBuffers();
}


sub DrawJet {
    glBegin(GL_TRIANGLES);
	#--------Nose Cone
	    #White
	glColor3ub(255, 255, 255);
	glVertex3f( 0.0,   0.0, 60.0 );
	glVertex3f(-15.0,  0.0, 30.0 );
	glVertex3f( 15.0,  0.0, 30.0 );
	    #Black
        glColor3ub(0, 0, 0);
	glVertex3f( 15.0,  0.0, 30.0 );
        glVertex3f(  0.0, 15.0, 30.0 );
	glVertex3f(  0.0,  0.0, 60.0 );
	    #Red
        glColor3ub(255, 0, 0);
	glVertex3f(  0.0,  0.0, 60.0 );
        glVertex3f(  0.0, 15.0, 30.0 );
	glVertex3f(-15.0,  0.0, 30.0 );
	#--------Body of Plane
	    #Green
	glColor3ub(0, 255, 0);
	glVertex3f(-15.0,  0.0, 30.0 );
	glVertex3f( 0.0,  15.0, 30.0 );
	glVertex3f( 0.0,   0.0,-56.0 );

	glColor3ub(255, 255, 0);
	glVertex3f( 0.0,   0.0,-56.0 );
	glVertex3f( 0.0,  15.0, 30.0 );
	glVertex3f( 15.0,  0.0, 30.0 );

	glColor3ub(0, 255, 255);
	glVertex3f( 15.0,  0.0, 30.0 );
	glVertex3f(-15.0,  0.0, 30.0 );
	glVertex3f(  0.0,  0.0,-56.0 );

	#--------Left wing
	    #large triangle bottom of wing
	glColor3ub(128, 128, 128);
	glVertex3f(  0.0,  2.0, 27.0 );
	glVertex3f(-60.0,  2.0, -8.0 );
	glVertex3f( 60.0,  2.0, -8.0 );

	glColor3ub(64, 64, 64);
	glVertex3f( 60.0,  2.0, -8.0 );
	glVertex3f(  0.0,  7.0, -8.0 );
	glVertex3f(  0.0,  2.0, 27.0 );

	glColor3ub(192, 192, 192);
	glVertex3f( 60.0,  2.0, -8.0 );
	glVertex3f(-60.0,  2.0, -8.0 );
	glVertex3f(  0.0,  7.0, -8.0 );
	    #Other wing top section
	glColor3ub(64, 64, 64);
	glVertex3f(  0.0,  2.0, 27.0 );
	glVertex3f(  0.0,  7.0, -8.0 );
	glVertex3f(-60.0,  2.0, -8.0 );
	#--------Tail section
	    #Bottom of back fin
	glColor3ub(255, 128, 255);
	glVertex3f(-30.0, -0.50, -57.0 );
	glVertex3f( 30.0, -0.50, -57.0 );
	glVertex3f(  0.0, -0.50, -40.0 );
	    #top of lect side
	glColor3ub(255, 128, 0);
	glVertex3f(  0.0, -0.50, -40.0 );
	glVertex3f( 30.0, -0.50, -57.0 );
	glVertex3f(  0.0,  4.0, -57.0 );
	    #top of right side
	glColor3ub(255, 128, 0);
	glVertex3f(  0.0,  4.0 , -57.0 );
	glVertex3f(-30.0, -0.50, -57.0 );
	glVertex3f(  0.0, -0.50, -40.0 );
	    #back of bottom of tail
	glColor3ub(255, 255, 255);
	glVertex3f( 30.0, -0.50, -57.0 );
	glVertex3f(-30.0, -0.50, -57.0 );
	glVertex3f(  0.0,  4.0 , -57.0 );

	#--------Top of tail section left
	glColor3ub(255, 0, 0);
	glVertex3f(  0.0,  0.50, -40.0 );
	glVertex3f(  3.0,  0.50, -57.0 );
	glVertex3f(  0.0, 25.0,  -65.0 );

	glColor3ub(255, 0, 0);
	glVertex3f(  0.0, 25.0,  -65.0 );
	glVertex3f( -3.0,  0.50, -57.0 );
	glVertex3f(  0.0,  0.50, -40.0 );
	    #Back of horizontal section
	glColor3ub(128, 128, 128);
	glVertex3f(  3.0,  0.50, -57.0 );
	glVertex3f( -3.0,  0.50, -57.0 );
	glVertex3f(  0.0, 25.0,  -65.0 );

	
    glEnd();
}

sub SetupRC {
    #glDisable(GL_CULL_FACE);	#Do not calculate inside of jet
    glEnable(GL_DEPTH_TEST);	#Hidden surface removal
    glEnable(GL_CULL_FACE);	#Do not calculate inside of jet
    glFrontFace(GL_CCW);	#Counter clock-wise polygons face out
    glClearColor(0.0, 0.0, 0.5, 1.0);
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
glutCreateWindow("Jet");
glutReshapeFunc(\&ChangeSizeOrtho);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
