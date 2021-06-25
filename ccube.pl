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
    my $nRange = 100.0;
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
	glOrtho(-$nRange, $nRange, -$windowHeight, $windowHeight, $nRange, -$nRange);
    } else {
	$windowWidth  = $nRange*$aspectRatio;
	$windowHeight = $nRange;
	glOrtho(-$windowWidth, $windowWidth, -$nRange, $nRange, $nRange, -$nRange);
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
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    	#Транслируем всю сцену в поле зрения наблюдателя
	#Это исходное преобразование наблюдения
	#Отойдем от центра "вселенной"
    glTranslatef(0.0, 0.0, -400.0); 
	#и установим нужный ракурс   
    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 1.0, 0.0);
	#Теперь рисуем сцену
    DrawColorCube(50.0);
    
    glPopMatrix();

    glutSwapBuffers();
}


sub DrawColorCube {
    my $half_side = shift;
	#Draw six quads
    glBegin(GL_QUADS);
	#Front Face
	#White
    glColor3ub(255, 255, 255);
    glVertex3f($half_side, $half_side, $half_side );
	#Yellow
    glColor3ub(255, 255, 0);
    glVertex3f($half_side, -$half_side, $half_side );
	#Red
    glColor3ub(255, 0, 0);
    glVertex3f(-$half_side, -$half_side, $half_side );
	#Magenta
    glColor3ub(255, 0, 255);
    glVertex3f(-$half_side, $half_side, $half_side );

	#Back Face
	#Cyan
    glColor3f(0.0, 1.0, 1.0);
    glVertex3f($half_side, $half_side, -$half_side );
	#Green
    glColor3f(0.0, 1.0, 0.0);
    glVertex3f($half_side, -$half_side, -$half_side );
	#Black
    glColor3f(0.0, 0.0, 0.0);
    glVertex3f(-$half_side, -$half_side, -$half_side );
	#Blue
    glColor3f(0.0, 0.0, 1.0);
    glVertex3f(-$half_side, $half_side, -$half_side );
    
	#Top Face
	#Cyan
    glColor3f(0.0, 1.0, 1.0);
    glVertex3f($half_side, $half_side, -$half_side );
	#White
    glColor3f(1.0, 1.0, 1.0);
    glVertex3f($half_side, $half_side, $half_side );
	#Magenta
    glColor3f(1.0, 0.0, 1.0);
    glVertex3f(-$half_side, $half_side, $half_side );
	#Blue
    glColor3f(0.0, 0.0, 1.0);
    glVertex3f(-$half_side, $half_side, -$half_side );
    
	#Bottom Face
	#Green
    glColor3f(0.0, 1.0, 0.0);
    glVertex3f($half_side, -$half_side, -$half_side );
	#Yellow
    glColor3f(1.0, 1.0, 0.0);
    glVertex3f($half_side, -$half_side, $half_side );
	#Red
    glColor3f(1.0, 0.0, 0.0);
    glVertex3f(-$half_side, -$half_side, $half_side );
	#Black
    glColor3f(0.0, 0.0, 0.0);
    glVertex3f(-$half_side, -$half_side, -$half_side );

	#Left Face
	#White
    glColor3f(1.0, 1.0, 1.0);
    glVertex3f($half_side, $half_side, $half_side );
	#Cyan
    glColor3f(0.0, 1.0, 1.0);
    glVertex3f($half_side, $half_side, -$half_side );
	#Green
    glColor3f(0.0, 1.0, 0.0);
    glVertex3f($half_side, -$half_side, -$half_side );
	#Yellow
    glColor3f(1.0, 1.0, 0.0);
    glVertex3f($half_side, -$half_side, $half_side );
    
	#Right Face
	#Magenta
    glColor3f(1.0, 0.0, 1.0);
    glVertex3f(-$half_side, $half_side, $half_side );
	#Blue
    glColor3f(0.0, 0.0, 1.0);
    glVertex3f(-$half_side, $half_side, -$half_side );
	#Black
    glColor3f(0.0, 0.0, 0.0);
    glVertex3f(-$half_side, -$half_side, -$half_side );
	#Red
    glColor3f(1.0, 0.0, 0.0);
    glVertex3f(-$half_side, -$half_side, $half_side );

    glEnd();
}

sub SetupRC {
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_DITHER);
    glShadeModel(GL_SMOOTH);
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
glutCreateWindow("Atom");
glutReshapeFunc(\&ChangeSizePerspect);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
