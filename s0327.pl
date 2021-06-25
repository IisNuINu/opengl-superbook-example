#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use OpenGL::Image;
use Data::Dumper;
use lib ".";
use gltFile qw/gltWriteFile/;

my ($w_img, $h_img, $img);
my ($def_fmt,$def_type);
my ($win_width, $win_height);
my $iRenderMode = 1;

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
    my $iModifiedBytes;
    glClear(GL_COLOR_BUFFER_BIT);
    glRasterPos2i(0, 0);
    if($iRenderMode == 2) {
	glPixelZoom(-1.0, -1.0);
	glRasterPos2i($w_img, $h_img);
    } elsif($iRenderMode == 3) {
	@iViewport = glGetIntegerv_p(GL_VIEWPORT);
	glPixelZoom($iViewport[2]/$w_img, $iViewport[3]/$h_img);
	#print "iViewport: ".Dumper(\@iViewport)."\n";
    } elsif($iRenderMode == 4) {	#Только красный
	glPixelTransferf(GL_RED_SCALE, 1.0);
	glPixelTransferf(GL_GREEN_SCALE, 0.0);
	glPixelTransferf(GL_BLUE_SCALE, 0.0);
    } elsif($iRenderMode == 5) {	#Только зеленый
	glPixelTransferf(GL_RED_SCALE, 0.0);
	glPixelTransferf(GL_GREEN_SCALE, 1.0);
	glPixelTransferf(GL_BLUE_SCALE, 0.0);
    } elsif($iRenderMode == 6) {	#Только синий
	glPixelTransferf(GL_RED_SCALE, 0.0);
	glPixelTransferf(GL_GREEN_SCALE, 0.0);
	glPixelTransferf(GL_BLUE_SCALE, 1.0);
    } elsif($iRenderMode == 7) {	#Черно-белый, более сложный режим
	$iModifiedBytes = new OpenGL::Image(engine=>'Magick', width=>$w_img, height=>$h_img);
	    #Вначале рисуем изображение в буфере цвета
        glDrawPixels_c($w_img, $h_img, $def_fmt, GL_UNSIGNED_BYTE, $img->Ptr());
	    #Маштабируем цвета согласно стандарту NSTC
	glPixelTransferf(GL_RED_SCALE, 0.3);
	glPixelTransferf(GL_GREEN_SCALE, 0.59);
	glPixelTransferf(GL_BLUE_SCALE, 0.11);
	    #Считываем пикселы в буфер(будет применено увеличение)
        glReadPixels_c(0, 0, $w_img, $h_img, GL_LUMINANCE, GL_UNSIGNED_BYTE, $iModifiedBytes->Ptr());
	    #Маштабирование цвета возвращаем в норму
	glPixelTransferf(GL_RED_SCALE, 1.0);
	glPixelTransferf(GL_GREEN_SCALE, 1.0);
	glPixelTransferf(GL_BLUE_SCALE, 1.0);
    } elsif($iRenderMode == 8) {	#Инверсия цветов
	my @invertMap;
	for(my $i = 1; $i < 256; $i++) {
	    push @invertMap, 1.0-(1.0/255.0 * $i);
	}
	glPixelMapfv_p(GL_PIXEL_MAP_R_TO_R, @invertMap);
	glPixelMapfv_p(GL_PIXEL_MAP_G_TO_G, @invertMap);
	glPixelMapfv_p(GL_PIXEL_MAP_B_TO_B, @invertMap);
	glPixelTransferi(GL_MAP_COLOR, GL_TRUE);
    }
    if(!defined($iModifiedBytes)) {
        #glDrawPixels_c($w_img, $h_img, $def_fmt, $def_type, $img->Ptr());
        glDrawPixels_c($w_img, $h_img, $def_fmt, GL_UNSIGNED_BYTE, $img->Ptr());
    } else {
        glDrawPixels_c($w_img, $h_img, GL_LUMINANCE, GL_UNSIGNED_BYTE, $iModifiedBytes->Ptr());
    }
	#Обновление всего до настроек по умолчанию
    glPixelTransferi(GL_MAP_COLOR, GL_FALSE);
    glPixelTransferf(GL_RED_SCALE, 1.0);
    glPixelTransferf(GL_GREEN_SCALE, 1.0);
    glPixelTransferf(GL_BLUE_SCALE, 1.0);
    glPixelZoom(1.0, 1.0);
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
    } else {
	$iRenderMode = $value;
    }
    glutPostRedisplay();
}


eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE );
glutInitWindowSize(800, 600);
glutCreateWindow("Imageload Example");
glutReshapeFunc(\&ChangeSize);
glutDisplayFunc(\&RenderScene);
    #Создание меню
glutCreateMenu(\&ProcessMenu);
glutAddMenuEntry("Save Image", 0);
glutAddMenuEntry("DrawPixels", 1);
glutAddMenuEntry("FlipPixels", 2);
glutAddMenuEntry("ZoomPixels", 3);
glutAddMenuEntry("Just Red Channel", 4);
glutAddMenuEntry("Just Green Channel", 5);
glutAddMenuEntry("Just Blue Channel", 6);
glutAddMenuEntry("Black and White", 7);
glutAddMenuEntry("Invert Colors", 8);
glutAttachMenu(GLUT_RIGHT_BUTTON);

glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
