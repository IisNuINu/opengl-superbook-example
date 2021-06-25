#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use Data::Dumper;

my $fire;
my ($wf, $hf);

sub loadbitmap_from_h {
    my $filename = shift;
    open(H, "<", $filename);
    my @lines = <H>;
    close(H);
    my @tmp_h; 
    my ($w, $h) = (0, 0);
    foreach my $l (@lines) {
	foreach my $he ($l =~ m/0[xX]([0-9a-fA-F]{2})/g) {
    	    $w++ if($h == 0);       #Ширину считаем только по 1 элементу массива
    	    push @tmp_h, $he;
	}
	$h++;
    }
    my @hex_char = map {hex($_)} @tmp_h;
    my $size = $w*$h;
    my $image = pack("C$size", @hex_char);  
    $w  *= 8;
    #print "width = $w, height = $h\n, image=".Dumper($image)."\n";
    return ($w, $h, $image);
}

sub SetupRC {
	#черный фон
    glClearColor(0.0, 0.0, 0.0, 1.0);
    ($wf, $hf, $fire) = loadbitmap_from_h("fire.h");
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
	#псевдокоординаты окна
    glOrtho(0.0, $w, 0.0, $h, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub RenderScene {
    my ($x, $y);
    glClear(GL_COLOR_BUFFER_BIT);
    glColor3f(1.0, 1.0, 1.0);
	#цикл из 16 строк
    for($y=0; $y<16;$y++) {
	glRasterPos2i(0, $y*32);
	for($x=0; $x<16;$x++) {
	    glBitmap_s(32, 32, 0.0, 0.0, 32.0, 0.0, $fire);
	}
    }
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
glutCreateWindow("Bitmap Example");
glutReshapeFunc(\&ChangeSize);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
