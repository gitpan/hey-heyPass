package hey::heyPass;

our $VERSION = "1.05";

use 5.005;
use LWP::UserAgent;
use XML::Simple;

my $xo = XML::Simple->new(KeyAttr => undef, NoIndent => 1, RootName => "xml");

my $ua = LWP::UserAgent->new();
$ua->agent("heyPass Client/$VERSION (client\@heypass.hey.nu)");

my $pageurl = "https://heypass.hey.nu/interface";

sub new {
  local $class = shift;
  (local $siteId = shift) =~ s|[^A-Za-z0-9]||g;
  (local $siteKey = shift) =~ s|[^A-Za-z0-9]||g;
  local $self = {
    _siteId => $siteId,
    _siteKey => $siteKey,
  };
  bless($self, $class);
  return $self;
}

sub request {
  local $self = shift;
  local $module = shift;
  local @content = @_;
  local @contentProcessed;
  for (local $i=0; $i <= $#content; $i++) {
    if (ref($content[$i]) eq "HASH") {
      local $key, $val;
      foreach $key (keys(%{$content[$i]})) {
        push(@contentProcessed, join("=", urlEncode($key), urlEncode($content[$i]->{$key})));
      }
    } else {
      push(@contentProcessed, $content[$i]);
    }
  }
  local $req = HTTP::Request->new(POST => "$pageurl/$module");
  local $content = join("&", "siteId=".$self->{_siteId}, "siteKey=".$self->{_siteKey}, @contentProcessed);
  $req->content($content);
  local $res = $ua->request($req);
  if ($res->is_success) {
    return $xo->XMLin($res->content);
  }
  return undef;
}

sub beginSession {
  local $self = shift;
  local $input = shift || {};
  local $ssl = ($input->{ssl} ? 1 : 0);
  local $successUrl = $input->{successUrl};
  local $failureUrl = $input->{failureUrl};
  local $cancelUrl = $input->{cancelUrl};
  local $res = $self->request("beginsession", { successUrl => $successUrl, failureUrl => $failureUrl, cancelUrl => $cancelUrl });
  unless ($res) {
    return undef;
  }
  return { sessionId => $res->{sessionId}, loginUrl => $res->{loginUrl} };
}

sub getSession {
  local $self = shift;
  local $sessionId = shift || return undef;
  local $res = $self->request("guestsession", {sessionId => $sessionId});
  unless ($res) {
    return undef;
  }
  return $res->{session};
}

sub endSession {
  local $self = shift;
  local $sessionId = shift || return undef;
  local $res = $self->request("endsession", {sessionId => $sessionId});
  unless ($res) {
    return undef;
  }
  return (lc($res->{status}) eq "success" ? 1 : undef);
}

sub loginButton {
  local $self = shift;
  local $loginUrl = shift || return undef;
  local $ssl = shift;
  $ssl = ($ssl ? 1 : 0);
  local $protocol = ($ssl ? "https://" : "http://");
  return qq(<a href="$loginUrl"><img src="${protocol}heypass.hey.nu/button/login.gif" border="0" title="heyPass Login"></a>);
}

sub logoutButton {
  local $self = shift;
  local $logoutUrl = shift || return undef;
  local $ssl = shift;
  $ssl = ($ssl ? 1 : 0);
  local $protocol = ($ssl ? "https://" : "http://");
  return qq(<a href="$logoutUrl"><img src="${protocol}heypass.hey.nu/button/logout.gif" border="0" title="heyPass Logout"></a>);
}

sub urlEncode {
  my $value = shift;
  $value =~ s|([^A-Za-z0-9])|sprintf("%%%2X", ord($1))|ge;
  $value =~ s|%20|+|g;
  return $value;
}

sub urlDecode {
  my $value = shift;
  $value =~ tr|+| |;
  $value =~ s|%([a-fA-F0-9][a-fA-F0-9])|pack("C", hex($1))|eg;
  return $value;
}

1;
__END__
=head1 NAME

hey::heyPass - Interface with heyPass Centralized Authentication System

=head1 SYNOPSIS

  # To send a user to login:
  use hey::heyPass;
  $heyPass = hey::heyPass->new($yourSiteId, $yourSiteKey);
  $login = $heyPass->beginSession({
             successUrl => "http://$ENV{HTTP_HOST}/loginSuccess.cgi?sessionId=%s",
             failureUrl => "http://$ENV{HTTP_HOST}/loginFailure.cgi?sessionId=%s",
             cancelUrl => "http://$ENV{HTTP_HOST}/loginCancel.cgi?sessionId=%s"
           });
  print "Location: $login->{loginUrl}\n\n";

  # To logout the user:
  use hey::heyPass;
  $heyPass = hey::heyPass->new($yourSiteId, $yourSiteKey);
  $heyPass->endSession($sessionId);

  # To retrieve the session data of the user:
  use hey::heyPass;
  $heyPass = hey::heyPass->new($yourSiteId, $yourSiteKey);
  $session = $heyPass->getSession($sessionId);
  use Data::Dumper;
  print Dumper($session);

=head1 DESCRIPTION

Documentation: https://heypass.hey.nu/interface/guestdocs/

If you want to have a heyPass siteId/siteKey for your application, please check to see if there is an automated way to do this (not yet at time of writing).  If there still isn't, contact me (Dusty Wilson <cpan-heypass@dusty.hey.nu>) and I will get you started.

=head1 DEPENDENCIES

LWP::UserAgent
XML::Simple
Crypt::SSLeay

=head1 THANKS

A big thank you goes out to all of our members at hey.nu Network who have helped us test heyPass throughly.  A special thank you goes to ssba for his testing and early adoption of heyPass in his projects.  And of course, thank you to the authors and contributors of LWP, XML::Simple, Crypt::SSLeay, and all dependent projects for making this module so easy to make.  If it weren't for them, I would have had to actually write real code to have done this.  Thanks!

=head1 SEE ALSO

Documentation: https://heypass.hey.nu/interface/guestdocs/

heyPass Site: https://heypass.hey.nu/ (doubtfully useful in its current state)

=head1 AUTHOR

Dusty Wilson, E<lt>cpan-heypass@dusty.hey.nuE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Dusty Wilson, hey.nu Network Community Services

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
