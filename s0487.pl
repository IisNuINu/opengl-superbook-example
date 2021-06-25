#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use lib ".";
use gltCommon qw/GL_PI/;

use constant SCREEN_X =>  800;
use constant SCREEN_Y =>  600;

my @ctrlPoint = (
    [-4.0, 0.0, 0.0],	#End point
    [-6.0, 4.0, 0.0],	#control point
    [ 6.0,-4.0, 0.0],	#control point
    [ 4.0, 0.0, 0.0]	#End point
);

sub DrawPoints {
    glPointSize(5.0);
    glBegin(GL_POINTS);
    foreach my $p (@ctrlPoint) {
	#print "P".Dumper($p)."\n";
	glVertex2fv_p($p->[0], $p->[1]);
    }
    glEnd();
}

sub RenderScene {
    glClear(GL_COLOR_BUFFER_BIT);
    my ($start, $end, $size) = (0, 100, 3);
    my @tmp = map { @$_ } @ctrlPoint;
    #print "tmp:\n".Dumper(\@tmp)."\n";
    #glMap1f_p(GL_MAP1_VERTEX_3, $start, $end, $size, $#ctrlPoint+1, \@tmp);
    #glMap1f_p(GL_MAP1_VERTEX_3, 0.0, 100.0, 3, $#ctrlPoint+1, \@tmp);
	#ага  функция glMap1f_p реализована не верно хотя вызывать по идее ее надо так
	#glMap1f_p(GL_MAP1_VERTEX_3, 0.0, 100.0, @tmp);
    	# вызов в OpenGL.xs выглядит так, что неправильно передает информацию о size:
	# glMap1f(target, u1, u2, 0, order, points);
	# но зато есть другие функции ими и воспользуемся
    my $numFloatVar = ($#ctrlPoint+1) *$size;
    my $t = pack("f$numFloatVar", @tmp);
	#Рисуем кривую безье
    glMap1f_s(GL_MAP1_VERTEX_3, $start, $end, $size, $#ctrlPoint+1, $t);
    glEnable(GL_MAP1_VERTEX_3);
    glMapGrid1d($end, $start, $end);
    glEvalMesh1(GL_LINE, $start, $end);
	#Рисуем контрольные точки
    DrawPoints();

    glutSwapBuffers();
}

sub SetupRC {
	#White background
    glClearColor(1.0, 1.0, 1.0, 1.0);
	#Blue drawing
    glColor3f(0.0, 0.0, 1.0);
}


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
	#Establish clipping volume (left, right, bottom, top, near, far)
    #gluOrtho2D(0.0, SCREEN_X, 0.0, SCREEN_Y);
    gluOrtho2D(-10.0, 10.0, -10.0, 10.0);    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}



sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b") {
	exit(0);
    }
}


eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(SCREEN_X, SCREEN_Y);
glutCreateWindow("2D Bezier Curve");
glutReshapeFunc(\&ChangeSize);
#glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
