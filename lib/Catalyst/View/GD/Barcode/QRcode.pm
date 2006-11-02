package Catalyst::View::GD::Barcode::QRcode;

use strict;
use warnings;

our $VERSION = '0.04';

use base qw(Catalyst::View);
use NEXT;
use Catalyst::Exception;

use GD::Barcode::QRcode;

__PACKAGE__->mk_accessors(qw( ecc version module_size img_type ));

sub new {
    my ($class, $c, $args) = @_;
    my $self = $class->NEXT::new($c);

    for my $field (keys %$args) {
        if ($self->can($field)) {
            $self->$field($args->{$field});
        } else {
            $c->log->debug("Unknown config parameter $field") if $c->debug;
        }
    }
}

sub process {
    my ($self, $c) = @_;
    
    my $conf = $c->stash->{qrcode_conf} || $self->config;

    my $ecc = $conf->{ecc} || $self->ecc || 'M';
    my $version = $conf->{version} || $self->version || 4;
    my $module_size = $conf->{module_size} || $self->module_size || 1;
    my $img_type = $conf->{img_type} || $self->img_type || 'png';

    my $text = $c->stash->{qrcode};
    my $qrcode = GD::Barcode::QRcode->new(
        $text, {
            Ecc => $ecc, 
            Version => $version, 
            ModuleSize => $module_size
        }
    );
    my $gd = $qrcode->plot();
    $c->res->content_type("image/$img_type");
    $c->res->body($gd->$img_type());
}

1;
__END__

=head1 NAME

Catalyst::View::GD::Barcode::QRcode - GD::Barcode::QRcode View Class


=head1 SYNOPSIS

Create a View class using the helper

    script/myapp_create.pl view QRcode GD::Barcode::QRcode

Configure variables in your application class

    package MyApp;

    MyApp->config(
        'View::QRcode' => {
            ecc         => 'M',
            version     => 4,
            module_size => 1,
            img_type    => 'png'
        },
    );

Or using YAML config file

    View::QRcode:
        ecc: 'M'
        version: 4
        module_size: 1
        img_type: 'png'

Add qrcode action to forward to the View on MyApp::Controller::Root

    sub qrcode : Local {
        my ( $self, $c ) = @_;
        $c->stash->{qrcode} = 'http://www.cpan.org';
        $c->forward( $c->view( 'QRcode' ) );
    }

Or change configuration dynamically

    sub qrcode : Local {
        my ( $self, $c ) = @_;
        $c->stash( 
            qrcode => 'http://www.cpan.org', 
            qrcode_conf => {
                ecc         => 'Q',
                version     => 5,
                module_size => 3,
                img_type    => 'gif',
            },
        );

        $c->forward( $c->view( 'QRcode' ) );
    }

If you use 'Catalyst::Plugin::DefaultEnd', in your application class

    sub qrcode : Local {
        my ( $self, $c) = @_;

        $c->stash->{qrcode} = 'http://www.cpan.org';
    }

    sub end : Private {
        my ( $self, $c ) = @_;
        $c->forward( $c->view( 'QRCode' ) ) if $c->stash->{qrcode};
        $self->NEXT::end( $c );
    }

Or with 'Catalyst::Action::RenderView'

    sub render : ActionClass('RenderView') {}

    sub end : Private {
        my ( $self, $c ) = @_;
        
        $c->detach( $c->view( 'QRCode' ) ) if $c->stash->{qrcode};
        $c->forward('render');
    }

Then you can get QRcode image from http://localhost:3000/qrcode

For Template::Toolkit

    <img src="[%c.uri_for('/qrcode') %]"/>

=head1 DESCRIPTION

Catalyst::View::GD::Barcode::QRcode is the Catalyst view class for GD::Barcode::QRcode, create QRcode barcode image with GD.

=head2 CONFIG VARIABLES

=over 4

=item ecc

ECC mode.  Select 'M', 'L', 'H' or 'Q' (Default = 'M').

=item version

Version ie. size of barcode image (Default = 4).

=item module_size

Size of modules (barcode unit) (Default = 1).

=item img_type 

Type of barcode image (Default = 'png').

=back


=head1 AUTHOR

Hideo Kimura C<< <<hide@hide-k.net>> >>


=head1 LICENSE

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.



=head1 SEE ALSO

F<Catalyst>, F<GD::Barcode::QRcode>.


=cut
