#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;

# см: file:///home/bear/doc/perl/OpenGL/72.html
# как вы уже знаете это инициализация
eval {glutInit(); 1} or die qq { This test requires GLUT };

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
	glOrtho(-100.0, 100.0, -100.0/$aspectRatio, 100.0/$aspectRatio, 1.0, -1.0);
    } else {
	glOrtho(-100.0*$aspectRatio, 100.0*$aspectRatio, -100.0, 100.0, 1.0, -1.0);
    }
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub RenderScene {
    glClear(GL_COLOR_BUFFER_BIT);
    glColor3f(1.0, 0.0, 0.0);
    glRectf(-25.0, 25.0, 25.0, -25.0);
    glFlush();
}

sub SetupRC {
    glClearColor(0.0, 0.0, 1.0, 1.0);
}

glutInitDisplayMode(GLUT_RGB | GLUT_SINGLE);
glutCreateWindow("GLRect");
glutDisplayFunc(\&RenderScene);
glutReshapeFunc(\&ChangeSize);
SetupRC();
glutMainLoop();
