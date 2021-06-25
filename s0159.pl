#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;

# Анимированный прыгающий квадрат с использованием трафарета
# как вы уже знаете это инициализация

my ($x1, $y1) = (0.0, 0.0);
my $rsize = 25;
my $delay = 33;

my ($xstep, $ystep) = (1.0, 1.0);
my ($windowWidth, $windowHeight);

sub ChangeSize {
    my ($w, $h) = @_;
    my $aspectRatio;
    if($h == 0) {	#предотвращает деление на 0
	$h = 1;
    }
    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    $aspectRatio = $w/$h;
    if($w <= $h) {
	$windowWidth  = 100.0;
	$windowHeight = 100.0/$aspectRatio;
	glOrtho(-100.0, 100.0, -$windowHeight, $windowHeight, 1.0, -1.0);
    } else {
	$windowWidth  = 100.0*$aspectRatio;
	$windowHeight = 100.0;
	glOrtho(-$windowWidth, $windowWidth, -100.0, 100.0, 1.0, -1.0);
    }
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub RenderScene {
    my $dRadius = 0.1;
    my $dAngle;
    glClearColor(0.0, 0.0, 0.1, 0.0);	#Очищаем синим цветом
    glClearStencil(0.0);
    glEnable(GL_STENCIL_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	#Рисуем трафарет
    glStencilFunc(GL_NEVER, 0x0, 0x0);
    glStencilOp(GL_INCR, GL_INCR, GL_INCR);
	#Спиральный узор создает трафарет
    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_LINE_STRIP);
	for($dAngle =0.0; $dAngle < 400.0; $dAngle += 0.1) {
	    glVertex2d($dRadius * cos($dAngle), $dRadius * sin($dAngle));
	    $dRadius *= 1.002;
	}
    glEnd();

    glStencilFunc(GL_NOTEQUAL, 0x1, 0x1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
	#Рисуем квадрат
    glColor3f(1.0, 0.0, 0.0);
    glRectf($x1, $y1, $x1+$rsize, $y1-$rsize);
    glutSwapBuffers();
}

sub TimerFunction {
    my $value = shift;
	#Рассчитаем направление движения
    if($x1 > $windowWidth-$rsize || $x1 < -$windowWidth) {
	$xstep = -$xstep;
    }
    if($y1 > $windowHeight || $y1 < -$windowHeight+$rsize) {
	$ystep = -$ystep;
    }
	#Вычисляем следующее положение
    $x1 += $xstep;
    $y1 += $ystep;
	#Провека границ
    if($x1 > ($windowWidth-$rsize+$xstep)) {
	$x1 = $windowWidth-$rsize-1;
    } elsif ($x1 < -($windowWidth+$xstep)) {
	$x1 = -$windowWidth-1;
    }
    if($y1 > ($windowHeight+$ystep)) {
	$y1 = $windowHeight-1;
    } elsif ($y1 < -($windowHeight-$rsize+$ystep)) {
	$y1 = -$windowHeight+$rsize-1;
    }
	#Перерисовываем сцену с новыми координатами(проста даем задание glut вызвать функцию RenderScene)
    glutPostRedisplay();
    glutTimerFunc($delay, \&TimerFunction, 1);
}

sub SetupRC {
    glClearColor(0.0, 0.0, 1.0, 0.0);
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_STENCIL);
glutCreateWindow("Bounce");
glutDisplayFunc(\&RenderScene);
glutReshapeFunc(\&ChangeSize);
glutTimerFunc($delay, \&TimerFunction, 1);
SetupRC();
glutMainLoop();
