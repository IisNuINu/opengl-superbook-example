#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;

my ($windowWidth, $windowHeight) = (800, 600);

#Рисуем треугольник
sub ChangeSize {
    my ($w, $h) = @_;
    my $aspectRatio;
    my $nRange = 250.0;
    if($h == 0) {       #предотвращает деление на 0
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
    glClear(GL_COLOR_BUFFER_BIT);
       # Enable smooth shading
    glShadeModel(GL_SMOOTH);

	# Draw the triangle
    glBegin(GL_TRIANGLES);
        # Red Apex
        glColor3ub(255, 0, 0);
        glVertex3f(0.0, 200.0, 0.0);

        # Green on the right bottom corner
        glColor3ub(0, 255, 0);
        glVertex3f(200.0, -70.0, 0.0);

        # Blue on the left bottom corner
        glColor3ub(0, 0, 255);
        glVertex3f(-200.0, -70.0, 0.0);
    glEnd();
    glutSwapBuffers();
}

sub SetupRC {
    #Black background
    glClearColor(0.0, 0.0, 0.0, 1.0);
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize($windowWidth, $windowHeight);
glutCreateWindow("RGB Triangle");
glutDisplayFunc(\&RenderScene);
glutReshapeFunc(\&ChangeSize);
SetupRC();
glutMainLoop();
