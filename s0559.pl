#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use lib ".";
use gltCommon qw/GL_PI/;

use constant SMALL_STARS =>  130;
my @vSmallStars;
use constant MEDIUM_STARS =>  40;
my @vMediumStars;
use constant LARGE_STARS =>  15;
my @vLargeStars;
my ($SmallStars, $MediumStars, $LargeStars);

use constant SCREEN_X =>  800;
use constant SCREEN_Y =>  600;


sub ProcessMenu {
    my $value = shift;
    if($value == 1) {
        # Turn on antialiasing, and give hint to do the best
        # job possible.
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
        glEnable(GL_POINT_SMOOTH);
        glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
        glEnable(GL_LINE_SMOOTH);
        glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
        glEnable(GL_POLYGON_SMOOTH);
        glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
    } elsif ($value == 2) {
        # Turn off blending and all smoothing
        glDisable(GL_BLEND);
        glDisable(GL_LINE_SMOOTH);
        glDisable(GL_POINT_SMOOTH);
        glDisable(GL_POLYGON_SMOOTH);
    }    
    glutPostRedisplay();
}

sub RenderScene {
    my $i;
    my ($x, $y, $r, $angle);
    $x = 700.0;
    $y = 500.0;
    $r = 50.0;
    $angle = 0.0;

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	#Everything is white
    glColor3f(1.0, 1.0, 1.0);
	# Using vertex arrays
    glEnableClientState(GL_VERTEX_ARRAY);
	#Draw small star
    glPointSize(3.0);
    #glBegin(GL_POINTS);
    #foreach my $s (@vSmallStars) {
    #	glVertex2fv_p(@$s)
    #}
    #glEnd();
    glVertexPointer_c(2, GL_FLOAT, 0, $SmallStars->ptr());
    glDrawArrays(GL_POINTS, 0, SMALL_STARS);
	#Draw medium star
    glPointSize(5.05);
    glVertexPointer_c(2, GL_FLOAT, 0, $MediumStars->ptr());
    glDrawArrays(GL_POINTS, 0, MEDIUM_STARS);
	#Draw largest star
    glPointSize(8.5);
    glVertexPointer_c(2, GL_FLOAT, 0, $LargeStars->ptr());
    glDrawArrays(GL_POINTS, 0, LARGE_STARS);

    #// Draw the "moon"
    glBegin(GL_TRIANGLE_FAN);
        glVertex2f($x, $y);
        for($angle = 0; $angle < 2.0 * GL_PI; $angle += 0.1) {
            glVertex2f($x + cos($angle) * $r, $y + sin($angle) * $r);
	}    
	glVertex2f($x + $r, $y);
    glEnd();

    #// Draw distant horizon
    glLineWidth(3.5);
    glBegin(GL_LINE_STRIP);
        glVertex2f(0.0, 25.0);
        glVertex2f(50.0, 100.0);
        glVertex2f(100.0, 25.0);
        glVertex2f(225.0, 125.0);
        glVertex2f(300.0, 50.0);
        glVertex2f(375.0, 100.0);
        glVertex2f(460.0, 25.0);
        glVertex2f(525.0, 100.0);
        glVertex2f(600.0, 20.0);
        glVertex2f(675.0, 70.0);
        glVertex2f(750.0, 25.0);
        glVertex2f(800.0, 90.0);
    glEnd();

    glutSwapBuffers();
}

sub SetupRC {
    my $i;
    for($i = 0; $i < SMALL_STARS; $i++) {
        my @a;
        $a[0] = rand(SCREEN_X) % SCREEN_X;
        $a[1] = (rand(SCREEN_Y) % (SCREEN_Y - 100)) + 100.0;
        push @vSmallStars, [@a];
    }
    for($i = 0; $i < MEDIUM_STARS; $i++) {
        my @a;
        $a[0] = (rand(SCREEN_X) % SCREEN_X * 10)/10.0;
        $a[1] = (rand(SCREEN_Y) % (SCREEN_Y - 100)) + 100.0;
        push @vMediumStars, [@a];
    }
    for($i = 0; $i < LARGE_STARS; $i++) {
        my @a;
        $a[0] = (rand(SCREEN_X) % SCREEN_X * 10)/10.0;
        $a[1] = (rand(SCREEN_Y) % (SCREEN_Y - 100) * 10.0)/10.0 + 100.0;
        push @vLargeStars, [@a];
    }
    print "SmallStars: ".Dumper(\@vSmallStars)."\n";
    print "MediumStars: ".Dumper(\@vMediumStars)."\n";
    print "LargeStars: ".Dumper(\@vLargeStars)."\n";
    $SmallStars = OpenGL::Array->new_list(GL_FLOAT, map { @$_ } @vSmallStars);
    $MediumStars= OpenGL::Array->new_list(GL_FLOAT, map { @$_ } @vMediumStars);
    $LargeStars = OpenGL::Array->new_list(GL_FLOAT, map { @$_ } @vLargeStars);
	#Black background
    glClearColor(0.0, 0.0, 0.0, 1.0);
	#white drawing
    glColor3f(0.0, 0.0, 0.0);
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
    gluOrtho2D(0.0, SCREEN_X, 0.0, SCREEN_Y);
    
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
glutCreateWindow("Smoothing Out The Jaggies");
    #Создание меню
glutCreateMenu(\&ProcessMenu);
glutAddMenuEntry("Antialiased Rendering", 1);
glutAddMenuEntry("Normal Rendering", 2);
glutAttachMenu(GLUT_RIGHT_BUTTON);

glutReshapeFunc(\&ChangeSize);
#glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
