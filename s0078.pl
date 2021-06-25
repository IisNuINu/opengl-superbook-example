#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;

# см: file:///home/bear/doc/perl/OpenGL/72.html
# как вы уже знаете это инициализация
eval {glutInit(); 1} or die qq { This test requires GLUT };

sub RenderScene {
    glClear(GL_COLOR_BUFFER_BIT);
    glFlush();
}

sub SetupRC {
    glClearColor(0.0, 0.0, 1.0, 1.0);
}

glutInitDisplayMode(GLUT_RGB | GLUT_SINGLE);
glutCreateWindow("Simple");
glutDisplayFunc(\&RenderScene);
SetupRC();
glutMainLoop();
