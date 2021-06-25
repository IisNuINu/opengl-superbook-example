package gltFrame;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltAddVectors);
use gltVector3;
use gltMatrix;
use OpenGL qw/:all/;
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = bless( {}, $class );
    $self->{'vLocation'} = [0.0, 0.0, 0.0];
    $self->{'vUp'}       = [0.0, 1.0, 0.0];
    $self->{'vForward'}  = [0.0, 0.0, -1.0];
    return $self;
}

sub clear {
    my ($self) = @_;
    $self->{'vLocation'} = [0.0, 0.0, 0.0];
    $self->{'vUp'}       = [0.0, 1.0, 0.0];
    $self->{'vForward'}  = [0.0, 0.0, -1.0];
    return $self;
}

sub CopyToMatrix {
    my ($self, $m) = @_;
	#Создадим вектор X
    my $vAxisX = gltVector3->new;
    $vAxisX->init($self->{'vUp'});
    $vAxisX->CrossProduct($self->{'vForward'});
    
	#@$m[0..2]  = @$vXAxis;
    $m->[0]  = $vAxisX->[0];
    $m->[1]  = $vAxisX->[1];
    $m->[2]  = $vAxisX->[2];
    $m->[3]  = 0.0;
	#@$m[4..6]  = @{$self->{'vUp'}};
    $m->[4]  = $self->{'vUp'}->[0];
    $m->[5]  = $self->{'vUp'}->[1];
    $m->[6]  = $self->{'vUp'}->[2];
    $m->[7]    = 0.0;
	#@$m[8..10] = @{$self->{'vForward'}};
    $m->[8]  = $self->{'vForward'}->[0];
    $m->[9]  = $self->{'vForward'}->[1];
    $m->[10] = $self->{'vForward'}->[2];
    $m->[11]   = 0.0;
	#@$m[12..14]= @{$self->{'vLocation'}};
    $m->[12]   = $self->{'vLocation'}->[0];
    $m->[13]   = $self->{'vLocation'}->[1];
    $m->[14]   = $self->{'vLocation'}->[2];
    $m->[15]   = 1.0;
}

sub print {
    my ($self, $name) = @_;
    print "Frame: '$name'\n";
    print "vLocation: x=$self->{vLocation}->[0],\ty=$self->{vLocation}->[1],\tz=$self->{vLocation}->[2]\n";
    print "vUp      : x=$self->{vUp}->[0],\ty=$self->{vUp}->[1],\tz=$self->{vUp}->[2]\n";
    print "vForward : x=$self->{vForward}->[0],\ty=$self->{vForward}->[1],\tz=$self->{vForward}->[2]\n";
    
}

sub ApplyActorTransform {
    my ($self) = @_;
    my $mTransform = gltMatrix->new();
    $self->CopyToMatrix($mTransform);
    glMultMatrixf_p(@$mTransform);
}

sub ApplyCameraTransform {
    my ($self) = @_;
    my $mMatrix = gltMatrix->new();
    my $vAxisX  = gltVector3->new();
    $vAxisX->init($self->{'vUp'});
    my $zFlipped= gltVector3->new();
    $zFlipped->init($self->{'vForward'});
    $zFlipped->mul_a(-1);
    
    $vAxisX->CrossProduct($zFlipped);
    
    $mMatrix->[0] = $vAxisX->[0];
    $mMatrix->[4] = $vAxisX->[1];
    $mMatrix->[8] = $vAxisX->[2];
    $mMatrix->[12]= 0.0;

    $mMatrix->[1] = $self->{'vUp'}->[0];
    $mMatrix->[5] = $self->{'vUp'}->[1];
    $mMatrix->[9] = $self->{'vUp'}->[2];
    $mMatrix->[13]= 0.0;

    $mMatrix->[2] = $zFlipped->[0];
    $mMatrix->[6] = $zFlipped->[1];
    $mMatrix->[10]= $zFlipped->[2];
    $mMatrix->[14]= 0.0;

    $mMatrix->[3] = 0.0;
    $mMatrix->[7] = 0.0;
    $mMatrix->[11]= 0.0;
    $mMatrix->[15]= 1.0;

    glMultMatrixf_p(@$mMatrix);

    glTranslatef(-$self->{vLocation}->[0], -$self->{vLocation}->[1], -$self->{vLocation}->[2]);
}

sub MoveForward {
    my ($self, $fStep) = @_;
    $self->{vLocation}->[0] += $self->{vForward}->[0] * $fStep;
    $self->{vLocation}->[1] += $self->{vForward}->[1] * $fStep;
    $self->{vLocation}->[2] += $self->{vForward}->[2] * $fStep;
}

sub MoveUp {
    my ($self, $fStep) = @_;
    $self->{vLocation}->[0] += $self->{vUp}->[0] * $fStep;
    $self->{vLocation}->[1] += $self->{vUp}->[1] * $fStep;
    $self->{vLocation}->[2] += $self->{vUp}->[2] * $fStep;
}

sub MoveRight {
    my ($self, $fStep) = @_;
    my $vCross = gltVector3->new;
    $vCross->init($self->{'vUp'});
    $vCross->CrossProduct($self->{vForward});
    $self->{vLocation}->[0] += $vCross->[0] * $fStep;
    $self->{vLocation}->[1] += $vCross->[1] * $fStep;
    $self->{vLocation}->[2] += $vCross->[2] * $fStep;
}

    #Перевод с использованием глобальных координат
sub TranslateWorld {
    my ($self, $x, $y, $z) = @_;
    $self->{vLocation}->[0] += $x;
    $self->{vLocation}->[1] += $y;
    $self->{vLocation}->[2] += $z;
}

    #Перевод с использованием Локальных координат
sub TranslateLocal {
    my ($self, $x, $y, $z) = @_;
    $self->MoveRight($x);
    $self->MoveUp($y);
    $self->MoveForward($z);
}

sub RotateLocalY {
    my ($self, $fAngle) = @_;
    my $mRotation = gltMatrix->new();
    my $vNewForward = gltVector3->new;
    $vNewForward->init($self->{'vForward'});

    $mRotation->MakeRotation($fAngle, $self->{vUp}->[0], $self->{vUp}->[1], $self->{vUp}->[2]);
    $vNewForward->Rotate($mRotation);
    $self->{vForward} = $vNewForward;
}

sub RotateLocalX {
    my ($self, $fAngle) = @_;
    my $mRotation = gltMatrix->new();
    my $vNewForward = gltVector3->new;
    $vNewForward->init($self->{'vForward'});
    my $vCross    = gltVector3->new;
    $vCross->init($self->{'vUp'});
    my $vNewUp    = gltVector3->new;
    $vNewUp->init($self->{'vUp'});
    $vCross->CrossProduct($self->{vForward});

    $mRotation->MakeRotation($fAngle, $vCross->[0], $vCross->[1], $vCross->[2]);
    
    $vNewForward->Rotate($mRotation);
    $self->{vForward} = $vNewForward;

    $vNewUp->Rotate($mRotation);
    $self->{vUp} = $vNewUp;
}

sub RotateLocalZ {
    my ($self, $fAngle) = @_;
    my $mRotation = gltMatrix->new();
    my $vNewUp    = gltVector3->new;
    $vNewUp->init($self->{'vUp'});

    $mRotation->MakeRotation($fAngle, $self->{vForward}->[0], $self->{vForward}->[1], $self->{vForward}->[2]);
    
    $vNewUp->Rotate($mRotation);
    $self->{vUp} = $vNewUp;
}



1;
