package gltVector3;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltAddVectors);

use gltMatrix;

sub new {
    my ($class, $x, $y, $z) = @_;
    $x = 0.0 unless(defined($x));
    $y = 0.0 unless(defined($y));
    $z = 0.0 unless(defined($z));
    #print "x=$x, y=$y, z=$z, class = $class\n";
    my $self = bless( [$x, $y, $z], $class );

    return $self;
}

sub init {
    my ($self, $v) = @_;
    $self->[0] = $v->[0];
    $self->[1] = $v->[1];
    $self->[2] = $v->[2];
    return $self;
}

sub add {
    my ($self, $v) = @_;
    $self->[0] += $v->[0];
    $self->[1] += $v->[1];
    $self->[2] += $v->[2];
    return $self;
}

sub Subtract {
    my ($self, $v) = @_;
    $self->[0] -= $v->[0];
    $self->[1] -= $v->[1];
    $self->[2] -= $v->[2];
    return $self;
}


sub copy {
    my ($self, $v) = @_;
    $v->[0] = $self->[0];
    $v->[1] = $self->[1];
    $v->[2] = $self->[2];
    return $self;
}

sub mul_a {
    my ($self, $a) = @_;
    $self->[0] *= $a;
    $self->[1] *= $a;
    $self->[2] *= $a;
    return $self;
}

sub GetLength {
    my ($self) = @_;
    return sqrt($self->[0]*$self->[0] + $self->[1]*$self->[1] + $self->[2]*$self->[2]);
}

sub Scale {
    my ($self, $fScale) = @_;
    $self->[0] *= $fScale;
    $self->[1] *= $fScale;
    $self->[2] *= $fScale;
    return $self;
}

sub CrossProduct {
    my ($self, $vV) = @_;
    my ($vUx, $vUy, $vUz) = @$self;
    $self->[0] =  $vUy*$vV->[2] - $vV->[1]*$vUz;
    $self->[1] = -$vUx*$vV->[2] + $vV->[0]*$vUz;
    $self->[2] =  $vUx*$vV->[1] - $vV->[0]*$vUy;
    return $self;
}

sub DotProduct {
    my ($self, $vV) = @_;
    return $self->[0]*$vV->[0] + $self->[1]*$vV->[1] + $self->[2]*$vV->[2];
}

sub Normalize {
    my ($self) = @_;
    my $fLength = 1.0 / $self->GetLength();
    $self->Scale($fLength);
    return $self;
}

sub Rotate {
    my ($self, $mRotation) = @_;
    my ($x, $y, $z) = @$self;
    $self->[0] = $mRotation->[0]*$x + $mRotation->[4]*$y + $mRotation->[8]*$z;
    $self->[1] = $mRotation->[1]*$x + $mRotation->[5]*$y + $mRotation->[9]*$z;
    $self->[2] = $mRotation->[2]*$x + $mRotation->[6]*$y + $mRotation->[10]*$z;
    return $self;
}


sub gltAddVectors {
    my ($f, $v) = @_;
    my $rez = gltVector3::new();
    $rez->init($f);
    return $rez.add($v);
}

sub gltNormalizeVector {
    my $vNormal = shift;
    $vNormal->Normalize();
}

sub gltGetNormalVector {
    my ($vP1, $vP2, $vP3) = @_;
    my $vV1 = gltVector3->new();
    my $vV2 = gltVector3->new();
    
    $vV1->init($vP2);    
    $vV1->Subtract($vP1);    
    $vV2->init($vP3);    
    $vV2->Subtract($vP1);    
    
    $vV1->CrossProduct($vV2);
    $vV1->Normalize();
    return $vV1;
}

    #Расчет уравнения плоскости по 3 точкам.
sub gltGetPlaneEquation {
    my ($vP1, $vP2, $vP3) = @_;
    my $vPlane = gltGetNormalVector($vP1, $vP2, $vP3);
    my $vPlane_3 = -($vPlane->[0]*$vP3->[0] + $vPlane->[1]*$vP3->[1] + $vPlane->[2]*$vP3->[2]);
    return @$vPlane, $vPlane_3; #возвращается массив из 4 значений
}

    #Расчет расстояния между точкой и плоскостью
sub gltDistanceToPlane {
    my ($vP, $vPlane) = @_;
    return $vPlane->[0]*$vP->[0] + $vPlane->[1]*$vP->[1] + $vPlane->[2]*$vP->[2]+$vPlane->[3];
}



1;