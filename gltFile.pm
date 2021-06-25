package gltFile;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltWriteFile);

use OpenGL qw/:all/;
use OpenGL::Image;
use Data::Dumper;

sub gltWriteFile {
    my $filename = shift; 
    my @iViewport = glGetIntegerv_p(GL_VIEWPORT);
    #print "Viewport:".Dumper(\@iViewport)."\n";
	#Считываем биты из буфера цвета
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glPixelStorei(GL_PACK_ROW_LENGTH, 0);
    glPixelStorei(GL_PACK_SKIP_ROWS, 0);
    glPixelStorei(GL_PACK_SKIP_PIXELS, 0);
	#Получаем текущие установки буфера чтени и записываем их
	#Переключаемся на последний буфер и выполняем операцию чтения
	#В конце концов востанавливаем состояние буфера чтения
    my $lastBuffer = glGetIntegerv_p(GL_READ_BUFFER);
    #print "LastBuffer: $lastBuffer\n";
    glReadBuffer(GL_FRONT);
    my $image = new OpenGL::Image(engine=>'Magick', width=>$iViewport[2], height=>$iViewport[3]);
    my  ($def_fmt,$def_type) = $image->Get('gl_format','gl_type');
    #glReadPixels_c(0, 0, $iViewport[2], $iViewport[3], GL_BGR, GL_UNSIGNED_BYTE, $image->Ptr());
    glReadPixels_c(0, 0, $iViewport[2], $iViewport[3], $def_fmt, $def_type, $image->Ptr());
    glReadBuffer($lastBuffer);
	#И запоминаем файл
    $image->Save($filename);
}


1;
