#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use OpenGL::Image;
use Data::Dumper;

my ($wf, $hf, $fire);
my ($def_fmt,$def_type);
my ($win_width, $win_height);

sub SetupRC {
	#черный фон
    glClearColor(0.0, 0.0, 0.0, 1.0);
    $fire = new OpenGL::Image(source=>'fire.tga');
    ($wf,$hf) = $fire->Get('width','height');
    ($def_fmt,$def_type) = $fire->Get('gl_format','gl_type');
}

sub ChangeSize {
    my ($w, $h) = @_;
    ($win_width, $win_height) = ($w, $h);
    my $aspectRatio;
    my $nRange = 100.0;
    if($h == 0) {	#предотвращает деление на 0
	$h = 1;
    }
    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	#псевдокоординаты окна
    glOrtho(0.0, $w, 0.0, $h, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub RenderScene {
    my ($x, $y);
    glClear(GL_COLOR_BUFFER_BIT);
    glPushMatrix();
    my $left = ($win_width-$wf)/2;
    $left = 0 if($left < 0);
    my $down = ($win_height-$hf)/2;
    $down = 0 if($down < 0);
    glRasterPos2i($left, $down);
    glDrawPixels_c($wf, $hf, $def_fmt, $def_type, $fire->Ptr());
    glPopMatrix();
    glutSwapBuffers();
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
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE );
glutInitWindowSize(800, 600);
glutCreateWindow("Imageload Example");
glutReshapeFunc(\&ChangeSize);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
