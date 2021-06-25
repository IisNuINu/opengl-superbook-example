#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use Data::Dumper;

use constant GL_PI =>  3.1415;
my ($xRot, $yRot, $zRot) = (0.0, 0.0, 0.0);
my ($windowWidth, $windowHeight);
my $iCull	= 1;
my $iDepth	= 1;
my $iOutline	= 1;
my $lenConus    = 50.0;		#Высота конуса!
my @deltaLen   = (10, 90);
my $rConus	= 50.0;		#Радиус основания конуса
my @deltaR      = (10, 90);


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
    my $iPivot = 1;	#Используется для того чтобы отмечать чередующиеся цвета
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	#Проверка установленных эффектов
    if($iCull) {	#Включаем отбор, если необходимо
	glEnable(GL_CULL_FACE);
    } else {
	glDisable(GL_CULL_FACE);
    }
    if($iDepth) {	#Активизируем проверку глубины, если необходимо
	glEnable(GL_DEPTH_TEST);
    } else {
	glDisable(GL_DEPTH_TEST);
    }
    if($iOutline) {	#рисуем заднюю сторону в форме каркаса, если необходимо
	glPolygonMode(GL_BACK, GL_LINE);
    } else {
	glPolygonMode(GL_BACK, GL_FILL);
    }
	#Save matrix and the rotation
    glPushMatrix();
    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 1.0, 0.0);
    glRotatef($zRot, 0.0, 0.0, 1.0);

	#Активизируем использование фактур
    glBegin(GL_TRIANGLE_FAN);
	glVertex3f(0.0, 0.0, $lenConus);
	for($angle = 0.0; $angle <= 2.0*GL_PI*3.0; $angle += (GL_PI/8.0)) {
    	    $x = $rConus*sin($angle);
    	    $y = $rConus*cos($angle);
    		#Чередуем красный и зеленый цвет
    	    if(($iPivot%2)== 0) {
    		glColor3f(0.0, 1.0, 0.0);
    	    } else {
    		glColor3f(1.0, 0.0, 0.0);
    	    }
    	    $iPivot++;
    	    glVertex2f($x, $y);
	}
    glEnd();
    
	#Начинаем новый веер треугольников, иминтирующий основание конуса
    glBegin(GL_TRIANGLE_FAN);
	$iPivot = 1;
	glVertex2f(0.0, 0.0);
	for($angle = 0.0; $angle <= 2.0*GL_PI*3.0; $angle += (GL_PI/8.0)) {
    	    $x = $rConus*sin($angle);
    	    $y = $rConus*cos($angle);
    		#Чередуем красный и зеленый цвет
    	    if(($iPivot%2)== 0) {
    		glColor3f(0.0, 1.0, 0.0);
    	    } else {
    		glColor3f(1.0, 0.0, 0.0);
    	    }
    	    $iPivot++;
    	    glVertex2f($x, $y);
	}
    glEnd();

    glPopMatrix();
    glutSwapBuffers();
}


sub SetupRC {
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glColor3f(0.0, 1.0, 0.0);
	#Цвет модели затенения
    glShadeModel(GL_FLAT);
        #Многоугольники с обходом по часовой стрелке считаются направленными вперед;
        #Поведение изменено на обратное, поскольку мы используем вееры многоугольников
    glFrontFace(GL_CW);
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
    my $is_movekey = 0;
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b") {
	exit(0);
    } elsif ($key eq 'Q') {
	$zRot += 5.0;
	$is_movekey = 1;
    } elsif ($key eq 'A') {
	$zRot -= 5.0;
	$is_movekey = 1;
    } elsif ($key eq 'W') {
	$lenConus += 5.0;
	$lenConus  = $deltaLen[1] if ($lenConus > $deltaLen[1]);
	$is_movekey = 1;
    } elsif ($key eq 'S') {
	$lenConus -= 5.0;
	$lenConus  = $deltaLen[0] if ($lenConus < $deltaLen[0]);
	$is_movekey = 1;
    } elsif ($key eq 'E') {
	$rConus += 5.0;
	$rConus  = $deltaR[1] if ($rConus > $deltaR[1]);
	$is_movekey = 1;
    } elsif ($key eq 'D') {
	$rConus -= 5.0;
	$rConus  = $deltaR[0] if ($rConus < $deltaR[0]);
	$is_movekey = 1;
    }
    
    if($is_movekey) {
	$zRot = 0.0   if($zRot > 356);
	$zRot = 355.0 if($zRot < -1);
	glutPostRedisplay();
    }
}

sub ProcessMenu {
    my $value = shift;
    if($value == 1) {
	$iDepth = !$iDepth;
    } elsif ($value == 2) {
	$iCull = !$iCull;
    } elsif ($value == 3) {
	$iOutline = !$iOutline;
    }    
    glutPostRedisplay();
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutCreateWindow("Triangle");
    #Создание меню
glutCreateMenu(\&ProcessMenu);
glutAddMenuEntry("Toggle depth test", 1);
glutAddMenuEntry("Toggle cull backface", 2);
glutAddMenuEntry("Toggle outline back", 3);
glutAttachMenu(GLUT_RIGHT_BUTTON);

glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
