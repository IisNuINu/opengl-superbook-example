#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use constant GL_PI =>  3.1415;
my ($xRot, $yRot) = (0.0, 0.0);
my $fElect1 = 0.0;

my ($windowWidth, $windowHeight);
my @sizes; # = (0.0, 0.0);        #Допустимые размеры точек ОпенГЛ
my $step;                #минимальный поддерживаемый инкремент размеров точек

sub ChangeSize {
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

sub RenderScene {
    my ($x, $y, $z, $angle);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    	#Транслируем всю сцену в поле зрения наблюдателя
	#Это исходное преобразование наблюдения
    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 1.0, 0.0);
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
    #glTranslatef(0.0, 0.0, -100.0);
	#Красное ядро
    glColor3ub(255, 0, 0);
    glutSolidSphere(10.0, 15, 15);
	#Желтые электроны
    glColor3ub(255, 255, 0);
	#Рисуем первый электрон
	#Записываем преобразование наблюдения
    glPushMatrix();
	#Поворачиваем на угол поворота
    glRotatef($fElect1, 0.0, 1.0, 0.0);
	#Трансляция элементаот начала координат на орбиту
    glTranslatef(90.0, 0.0, 0.0);
	#Рисуем сам электрон
    glutSolidSphere(6.0, 15, 15);
    glPopMatrix();
	#Рисуем второй электрон
    glPushMatrix();
    glRotatef(45.0, 0.0, 0.0, 1.0);
    glRotatef($fElect1, 0.0, 1.0, 0.0);
    glTranslatef(-70.0, 0.0, 0.0);
    glutSolidSphere(6.0, 15, 15);
    glPopMatrix();
	#Рисуем третий электрон
    glPushMatrix();
    glRotatef(360.0, -45.0, 0.0, 1.0);
    glRotatef($fElect1, 0.0, 1.0, 0.0);
    glTranslatef(0.0, 0.0, 60.0);
    glutSolidSphere(6.0, 15, 15);
    glPopMatrix();
	#увеличиваем угол поворота
    glutSwapBuffers();
}

sub TimerFunc {
    my $val= shift;

    $fElect1 += 10.0;
    if($fElect1 > 360.0) {
	$fElect1 -= 360.0;
    }
    
    glutPostRedisplay();
    glutTimerFunc(100, \&TimerFunc, 1);
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
glutInitWindowSize(800, 600);
glutCreateWindow("Atom");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
