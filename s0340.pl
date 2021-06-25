#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use OpenGL::Image;
use Data::Dumper;
use lib ".";
use gltFile qw/gltWriteFile/;
use gltExt qw/gltIsExtSupported/;

my ($w_img, $h_img, $img);
my ($def_fmt,$def_type);
my ($win_width, $win_height);
my $iRenderMode = 1;
my $IsNeedHistogram  = 0;

sub SetupRC {
	#черный фон
    glClearColor(0.0, 0.0, 0.0, 1.0);
    $img = new OpenGL::Image(source=>'horse.tga');
    ($w_img,$h_img) = $img->Get('width','height');
    ($def_fmt,$def_type) = $img->Get('gl_format','gl_type');
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
    my @iViewport;
    my ($i, $iLargest);
    my @invertTable;
    my $lumMat = [
	0.30, 0.30, 0.30, 0.0,
	0.59, 0.59, 0.59, 0.0,
	0.11, 0.11, 0.11, 0.0,
	0.0,  0.0,  0.0,  1.0
    ];
    my @mSharpen = (
	 0.0, -1.0, 0.0,
	-1.0,  5.0,-1.0,
	 0.0, -1.0, 0.0
    );
    my @mEmboss = (
	 2.0,  0.0, 0.0,
	 0.0, -1.0, 0.0,
	 0.0,  0.0,  -1.0
    );
    my @histoGram;
    
    glClear(GL_COLOR_BUFFER_BIT);
    glRasterPos2i(0, 0);
    @iViewport = glGetIntegerv_p(GL_VIEWPORT);
    glPixelZoom($iViewport[2]/$w_img ,$iViewport[3]/$h_img);
    my $sizeHist = 256;
    my $sizeColor= 256;
    if($IsNeedHistogram) {
	glMatrixMode(GL_COLOR);
	    #когда работаем в режиме гистограммы для подсчета приходиться сбрасывать цвет на рисунке.
	glLoadMatrixf_p(@$lumMat);
	glMatrixMode(GL_MODELVIEW);
	    #Start collecing histogram date, 256 luminance values
	&gltExt::glHistogram(GL_HISTOGRAM, $sizeHist, GL_LUMINANCE, GL_FALSE);
	glEnable(GL_HISTOGRAM);
    }
    if($iRenderMode == 2) {	#увеличить яркость изображения
	glMatrixMode(GL_COLOR);
	glScalef(1.25, 1.25, 1.25);
	glMatrixMode(GL_MODELVIEW);
    } elsif($iRenderMode == 3) {	#Инверсия изображения
	for($i=0; $i<$sizeColor; $i++) {
	    push @invertTable, ($sizeColor-1-$i);
	    push @invertTable, ($sizeColor-1-$i);
	    push @invertTable, ($sizeColor-1-$i);
	}
	gltExt::glColorTable(GL_COLOR_TABLE, GL_RGB, $sizeColor, GL_RGB, GL_UNSIGNED_BYTE, \@invertTable);
        glEnable(GL_COLOR_TABLE);
    } elsif($iRenderMode == 4) {	#Тисненое изображение
	gltExt::glConvolutionFilter2D(GL_CONVOLUTION_2D, GL_RGB, 3, 3, GL_LUMINANCE, GL_FLOAT, \@mEmboss);
        glEnable(GL_CONVOLUTION_2D);
	glMatrixMode(GL_COLOR);
	glLoadMatrixf_p(@$lumMat);
	glMatrixMode(GL_MODELVIEW);
    } elsif($iRenderMode == 7) {	#Тисненое изображение
	gltExt::glConvolutionFilter2D(GL_CONVOLUTION_2D, GL_RGB, 3, 3, GL_LUMINANCE, GL_FLOAT, \@mEmboss);
        glEnable(GL_CONVOLUTION_2D);
	glMatrixMode(GL_COLOR);
	#glLoadMatrixf_p(@$lumMat);
	glMatrixMode(GL_MODELVIEW);
    } elsif($iRenderMode == 5) {	#Наведение резкости изображения
	gltExt::glConvolutionFilter2D(GL_CONVOLUTION_2D, GL_RGB, 3, 3, GL_LUMINANCE, GL_FLOAT, \@mSharpen);
        glEnable(GL_CONVOLUTION_2D);
    }

    glDrawPixels_c($w_img, $h_img, $def_fmt, GL_UNSIGNED_BYTE, $img->Ptr());
    if($IsNeedHistogram) {#рисуе гистограмму
    	    #// Read histogram data into buffer
	@histoGram = gltExt::glGetHistogram(GL_HISTOGRAM, GL_TRUE, GL_LUMINANCE, GL_INT, $sizeHist);
    	    #Find largest value for scaling graph down
        $iLargest = 0;
        for($i = 0; $i < 255; $i++) {
            if($iLargest < $histoGram[$i]) {
                $iLargest = $histoGram[$i];
            }
        }

    	    #// White lines
        glColor3f(1.0, 1.0, 1.0);
        glBegin(GL_LINE_STRIP);
            for($i = 0; $i < 255; $i++) {
                glVertex2f($i, $histoGram[$i] / $iLargest * 128.0);
            }
        glEnd();

        glDisable(GL_HISTOGRAM);
	
    
    }
	#Обновление всего до настроек по умолчанию
    glMatrixMode(GL_COLOR);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glDisable(GL_CONVOLUTION_2D);
    glDisable(GL_COLOR_TABLE);
	#Переключаем буфер
    glutSwapBuffers();
}


sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b" or $key eq 'Q') {
	exit(0);
    }
    if($key eq 'S') {
	gltWriteFile("ScreenShot.jpg");
    }
}

sub ProcessMenu {
    my $value = shift;
    if($value == 0) {
	gltWriteFile("ScreenShot.jpg");
    } elsif($value == 6) { #Switch Histogram draw
	$IsNeedHistogram = 1 - $IsNeedHistogram;
    } else {
	$iRenderMode = $value;
    }
    glutPostRedisplay();
}


eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE );
glutInitWindowSize(800, 600);
glutCreateWindow("OpenGL Imaging subset");
if(gltIsExtSupported("GL_ARB_imaging") == 0) {
    print "Imaging subset not supported\n";
    exit(0);
}
glutReshapeFunc(\&ChangeSize);
glutDisplayFunc(\&RenderScene);
    #Создание меню
glutCreateMenu(\&ProcessMenu);
glutAddMenuEntry("Save Image", 0);
glutAddMenuEntry("Raw Stretched Image", 1);
glutAddMenuEntry("Increase Contrast", 2);
glutAddMenuEntry("Invert Color", 3);
glutAddMenuEntry("Emboss Image", 4);
glutAddMenuEntry("Emboss Image_tst", 7);
glutAddMenuEntry("Sharpen Image", 5);
glutAddMenuEntry("Histogram", 6);
glutAttachMenu(GLUT_RIGHT_BUTTON);

glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
