#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use OpenGL::Image;
use lib ".";
use gltCommon qw/GL_PI/;
use gltVector3;
use hummer_data;
#use gltTools qw/gltDrawUnitAxes/;
my ($xRot, $yRot, $zRot) = (0.0, 0.0, 0.0);

my ($windowWidth, $windowHeight);
my ($headList, $shaftList, $threadList);

my $face_indicies = \@{hummer_data::face_indicies};
my $normals       = \@{hummer_data::normals};
my $textures      = \@{hummer_data::textures};
my $vertices      = \@{hummer_data::vertices};

my (@uiIndexes, @vVerts, @vText, @vNorms);
my ($a_uiIndexes, $a_vVerts, $a_vText, $a_vNorms);
my $iLastIndex = 0;

#Textures
my ($w_img, $h_img, $img);
my ($def_ifmt, $def_fmt,$def_type);
my @TextureFiles = ('hummer.tga');
my @textureObjects;

use constant   HUMMER_TEXTURE => 0;

#Display list
my $dlHummer;

sub ChangeSize {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 50.0;
    if($h == 0) {    #предотвращает деление на 0
        $h = 1;
    }
    glViewport(0, 0, $w, $h);
    $fAspect = $w/$h;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    gluPerspective(35.0, $fAspect, 0.1, $nRange);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

#Рисуем предположительно корабль
sub DrawHummer {
    my ($iFace, $iPoint);
    if(!defined($a_uiIndexes)) {
	IndexTriangles();
	#print "uiIndexes: ".Dumper(\@uiIndexes)."\n";
	#print "vVerts: ".Dumper(\@vVerts)."\n";
	print "Verts = $#vVerts, Indexes = $#uiIndexes\n";
	$a_uiIndexes = OpenGL::Array->new_list(GL_UNSIGNED_SHORT, @uiIndexes);
	$a_vVerts    = OpenGL::Array->new_list(GL_FLOAT,          map { @$_ } @vVerts);
	$a_vNorms    = OpenGL::Array->new_list(GL_FLOAT,          map { @$_ } @vNorms);
	$a_vText     = OpenGL::Array->new_list(GL_FLOAT,          map { @$_ } @vText );
    }
	# Use vertices, normals, and texture coordinates
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	# Here's where the data is now
    glVertexPointer_c(3, GL_FLOAT,0, $a_vVerts->ptr());
    glNormalPointer_c(GL_FLOAT, 0, $a_vNorms->ptr());
    glTexCoordPointer_c(2, GL_FLOAT, 0, $a_vText->ptr());

	#// Draw them
    glDrawElements_c(GL_TRIANGLES, $#uiIndexes, GL_UNSIGNED_SHORT, $a_uiIndexes->ptr());
    
}

sub IsSame {
    my ($x, $y, $epsilon) = @_;
    return (abs($x-$y) < $epsilon) ? 1 : 0;
}

# Goes through the arrays and looks for duplicate verticies
# that can be shared. This expands the original array somewhat
# and returns the number of true unique verticies that now
# populates the vVerts array.
sub IndexTriangles {
    #print "Stat IndexTriangles\n";
    my $e = 0.000001;
    my ($iFace, $iPoint, $iMatch);
    for($iFace = 0; $iFace <= $#$face_indicies; $iFace++) {
	#print "Work Face $iFace\n";
        for($iPoint = 0; $iPoint < 3; $iPoint++)  {
	    #print "Work Point $iPoint\n";
    	    for($iMatch = 0; $iMatch < $iLastIndex; $iMatch++)  {
                if(IsSame($vertices->[$face_indicies->[$iFace]->[$iPoint]]->[0], $vVerts[$iMatch]->[0], $e) and
                   IsSame($vertices->[$face_indicies->[$iFace]->[$iPoint]]->[1], $vVerts[$iMatch]->[1], $e) and
                   IsSame($vertices->[$face_indicies->[$iFace]->[$iPoint]]->[2], $vVerts[$iMatch]->[2], $e) and

                	#// AND the Normal is the same...
                   IsSame($normals->[$face_indicies->[$iFace]->[$iPoint+3]]->[0], $vNorms[$iMatch]->[0], $e) and
                   IsSame($normals->[$face_indicies->[$iFace]->[$iPoint+3]]->[1], $vNorms[$iMatch]->[1], $e) and
                   IsSame($normals->[$face_indicies->[$iFace]->[$iPoint+3]]->[2], $vNorms[$iMatch]->[2], $e) and

                	#// And Texture is the same...
                   IsSame($textures->[$face_indicies->[$iFace]->[$iPoint+6]]->[0], $vText[$iMatch]->[0], $e) and
                   IsSame($textures->[$face_indicies->[$iFace]->[$iPoint+6]]->[1], $vText[$iMatch]->[1], $e)) {
                	# Then add the index only
                	push @uiIndexes, $iMatch;
                	#$iIndexCount++;
			#print "Find double index: $iMatch\n";
                	last;
                }
	    }
	    #print "in point: iMatch=$iMatch, uiIndexes=$#uiIndexes\n";
            
		# No match found, add this vertex to the end of our list, and update the index array
            if($iMatch == $iLastIndex) {
            	    # Add data and new index
                push @vVerts, [@{ $vertices->[$face_indicies->[$iFace]->[$iPoint  ]]}];
                push @vNorms, [@{ $normals-> [$face_indicies->[$iFace]->[$iPoint+3]]}];
                push @vText,  [@{ $textures->[$face_indicies->[$iFace]->[$iPoint+6]]}];
                push @uiIndexes, $iMatch;
		#print "Add new index: $iMatch\n";
                #$iIndexCount++;
                $iLastIndex++;
            }

	}
    }
    #print "End IndexTriangles\n";
    return $#uiIndexes; 	#$iIndexCount;
}

sub RenderScene {
    my ($x, $y, $z, $angle);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
	glTranslatef(0.0, 0.0, -15.0);
	glRotatef($xRot, 1.0, 0.0, 0.0);
	glRotatef($yRot, 0.0, 1.0, 0.0);
	glRotatef($zRot, 0.0, 0.0, 1.0);
	
	DrawHummer();
	#glCallList($dlHummer);
    glPopMatrix();

    glutSwapBuffers();
}


sub SetupRC {
    my @ambientLight = (0.1, 0.1, 0.1, 1.0);
    my @diffuseLight = (1.0, 1.0, 1.0, 1.0);
    my @lightPos     = (-10.0, 100.0, 20.0, 1.0);

    glClearColor(0.0, 0.0, 0.5, 1.0);
    glEnable(GL_DEPTH_TEST);    #Hidden surface removal
    glEnable(GL_CULL_FACE);     #Do not calculate inside of jet
    #glFrontFace(GL_CCW);        #Counter clock-wise polygons face out

        #Textures load
    @textureObjects = glGenTextures_p($#TextureFiles+1);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    foreach my $i (0..$#TextureFiles) {
        my $name_f =$TextureFiles[$i];
        glBindTexture(GL_TEXTURE_2D, $textureObjects[$i]);
        $img = new OpenGL::Image(source=>$name_f);
        ($w_img,$h_img) = $img->Get('width','height');
        ($def_ifmt, $def_fmt,$def_type) = $img->Get('gl_internalformat', 'gl_format','gl_type');
            #Texture set
	my $gluerr;
        if ($gluerr =gluBuild2DMipmaps_c(GL_TEXTURE_2D,  $def_ifmt, $w_img, $h_img, $def_fmt,
              $def_type,$img->Ptr() )) {
            printf STDERR "GLULib%s\n", gluErrorString($gluerr);
            exit(-1);
        }
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    }
    glEnable(GL_TEXTURE_2D);

        #// Lighting stuff
    glEnable(GL_LIGHTING);      # Enable lighting
    glEnable(GL_COLOR_MATERIAL); # Enable Material color tracking
        # Front material ambient and diffuse colors track glColor
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
       #// Supply a slight ambient light so the objects can be seen
    glLightfv_p(GL_LIGHT0, GL_AMBIENT,  @ambientLight );
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE,  @diffuseLight );

        # Position and turn on the light
    glLightfv_p(GL_LIGHT0,GL_POSITION,@lightPos);
    glEnable(GL_LIGHT0);

	# Get Display list names
    $dlHummer = glGenLists(1);
	# Prebuild the display lists
    glNewList($dlHummer, GL_COMPILE);
        DrawHummer();
    glEndList();
}

sub SpecialKeys {
    my ($key, $x, $y) = @_;
    if($key == GLUT_KEY_UP) {
	$xRot -= 5.0;
    } elsif($key == GLUT_KEY_DOWN) {
	$xRot += 5.0;
    } elsif($key == GLUT_KEY_LEFT) {
	$yRot -= 5.0;
    } elsif($key == GLUT_KEY_RIGHT) {
	$yRot += 5.0;
    }
    
    $xRot %= 360.0;
    $yRot %= 360.0;
    
    glutPostRedisplay();
}

sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b") {
	exit(0);
    }
    if($key eq 'Q') {
	$zRot -= 5.0;
    } elsif( $key eq 'A') {
	$zRot += 5.0;
    }
    $zRot %= 360.0;
    glutPostRedisplay();
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
glutCreateWindow("Ship Display Lists");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
