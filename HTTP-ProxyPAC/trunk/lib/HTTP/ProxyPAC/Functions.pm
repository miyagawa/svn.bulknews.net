package HTTP::ProxyPAC::Functions;
use strict;
use IO::Socket; # inet_aton, inet_ntoa
use Sys::Hostname;

our @PACFunctions = qw(
    isPlainHostName
    dnsDomainIs
    localHostOrDomainIs
    isResolvable
    isInNet
    dnsResolve
    myIpAddress
    dnsDomainLevels
    shExpMatch
    weekDayRange
    dateRange
    timeRange
);

##############################################################################
#
# isPlainHostName - PAC command that tells if this is a plain host name
#                   (no dots)
#
##############################################################################
sub isPlainHostName {
  my ($host) = @_;

  return (($host =~ /\./) ? 0 : 1);
}


##############################################################################
#
# dnsDomainIs - PAC command to tell if the host is in the domain.
#
##############################################################################
sub dnsDomainIs {
  my ($host,$domain) = @_;

  $domain =~ s/\./\\\./;
  return (($host =~ /$domain$/) ? 1 : 0);
}


##############################################################################
#
# localHostOrDomainIs - PAC command to tell if the host matches, or if it is
#                       unqaulifed and in the domain.
#
##############################################################################
sub localHostOrDomainIs {
  my ($host,$hostdom) = @_;

  return 1 if ($host eq $hostdom);
  return 0 if ($host =~ /\./);
  return 1 if ($hostdom =~ /^$host/);
}


##############################################################################
#
# isResolvable - PAC command to see if the host can be resolved via DNS.
#
##############################################################################
sub isResolvable {
  my ($host) = @_;
  return (defined(gethostbyname($host)) ? 1 : 0);
}


##############################################################################
#
# isInNet - PAC command to see if the IP address is in this network based on
#           the mask and pattern.
#
##############################################################################
sub isInNet {
  my ($host,$pattern,$mask) = @_;

  my $addr = dnsResolve($host);
  return unless defined($addr);

  my @addr = split(/\./,$addr);
  my @mask = split(/\./,$mask);
  my @pattern;

  foreach my $count (0..3) {
    my $bitAddr = dec2bin($addr[$count]);
    my $bitMask = dec2bin($mask[$count]);

    $pattern[$count] = bin2dec($bitAddr & $bitMask);
  }

  my $hostPattern = join(".",@pattern);
  return (($pattern eq $hostPattern) ? 1 : 0);
}


##############################################################################
#
# dec2bin - decimal to binary conversion
#
##############################################################################
sub dec2bin {
  my $str = unpack("B32", pack("N", shift));
  return $str;
}


##############################################################################
#
# bin2dec - binary to decimal conversion
#
##############################################################################
sub bin2dec {
  return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}


##############################################################################
#
# dnsResolve - PAC command to get the IP from the host name.
#
##############################################################################
sub dnsResolve {
  my ($host) = @_;
  return unless isResolvable($host);
  return inet_ntoa(inet_aton($host));
}


##############################################################################
#
# myIpAddress - PAC command to get your IP.
#
##############################################################################
sub myIpAddress {
  return inet_ntoa(inet_aton(hostname()));
}


##############################################################################
#
# dnsDomainLevels - PAC command to tell how many domain levels there are in
#                   the host name (number of dots).
#
##############################################################################
sub dnsDomainLevels {
  my ($host) = @_;

  my $count = 0;
  foreach my $piece (split(/(\.)/,$host)) {
    $count++ if ($piece eq ".");
  }
  return $count;
}


##############################################################################
#
# shExpMatch - PAC command to see if a URL/path matches the shell expression.
#              Shell expressions are like  */foo/*  or http://*.
#
##############################################################################
sub shExpMatch {
  my ($str,$shellExp) = @_;

  $shellExp =~ s/\//\\\//g;
  $shellExp =~ s/\*/\.\*/g;

  return (($str =~ /$shellExp/) ? 1 : 0);
}


##############################################################################
#
# weekDayRange - PAC command to see if the current weekday falls within a
#                range.
#
##############################################################################
sub weekDayRange {
  my $wd1 = shift;
  my $wd2 = "";
  $wd2 = shift if ($_[0] ne "GMT");
  my $gmt = "";
  $gmt = shift if ($_[0] eq "GMT");

  my %wd = ( SUN=>0,MON=>1,TUE=>2,WED=>3,THU=>4,FRI=>5,SAT=>6);
  my $dow = (($gmt eq "GMT") ? (gmtime)[6] : (localtime)[6]);

  if ($wd2 eq "") {
    return (($dow eq $wd{$wd1}) ? 1 : 0);
  } else {
    my @range;
    if ($wd{$wd1} < $wd{$wd2}) {
      @range = ($wd{$wd1}..$wd{$wd2});
    } else {
      @range = ($wd{$wd1}..6,0..$wd{$wd2});
    }
    foreach my $tdow (@range) {
      return 1 if ($dow eq $tdow);
    }
    return 0;
  }
  return 0;
}


##############################################################################
#
# dateRange - PAC command to see if the current date falls within a range.
#
##############################################################################
sub dateRange {
  my %mon = ( JAN=>0,FEB=>1,MAR=>2,APR=>3,MAY=>4,JUN=>5,JUL=>6,AUG=>7,SEP=>8,OCT=>9,NOV=>10,DEC=>11);

  my %args;
  my $dayCount = 1;
  my $monCount = 1;
  my $yearCount = 1;

  while ($#_ > -1) {
    if ($_[0] eq "GMT") {
      $args{gmt} = shift;
    } elsif (exists($mon{$_[0]})) {
      my $month = shift;
      $args{"mon$monCount"} = $mon{$month};
      $monCount++;
    } elsif ($_[0] > 31) {
      $args{"year$yearCount"} = shift;
      $yearCount++;
    } else {
      $args{"day$dayCount"} = shift;
      $dayCount++;
    }
  }

  my $mday = (exists($args{gmt}) ? (gmtime)[3] : (localtime)[3]);
  my $mon = (exists($args{gmt}) ? (gmtime)[4] : (localtime)[4]);
  my $year = 1900+(exists($args{gmt}) ? (gmtime)[5] : (localtime)[5]);

  if (exists($args{day1}) && exists($args{mon1}) && exists($args{year1}) &&
      exists($args{day2}) && exists($args{mon2}) && exists($args{year2})) {

    if (($args{year1} < $year) && ($args{year2} > $year)) {
      return 1;
    } elsif (($args{year1} == $year) && ($args{mon1} <= $mon)) {
      return 1;
    } elsif (($args{year2} == $year) && ($args{mon2} >= $mon)) {
      return 1;
    } else {
      return 0;
    }
    return 0;


  } elsif (exists($args{mon1}) && exists($args{year1}) &&
	   exists($args{mon2}) && exists($args{year2})) {
    if (($args{year1} < $year) && ($args{year2} > $year)) {
      return 1;
    } elsif (($args{year1} == $year) && ($args{mon1} < $mon)) {
      return 1;
    } elsif (($args{year2} == $year) && ($args{mon2} > $mon)) {
      return 1;
    } elsif (($args{year1} == $year) && ($args{mon1} == $mon) &&
	     ($args{day1} <= $mday)) {
      return 1;
    } elsif (($args{year2} == $year) && ($args{mon2} == $mon) &&
	     ($args{day2} >= $mday)) {
      return 1;
    } else {
      return 0;
    }
    return 0;
  } elsif (exists($args{day1}) && exists($args{mon1}) &&
	   exists($args{day2}) && exists($args{mon2})) {
    if (($args{mon1} < $mon) && ($args{mon2} > $mon)) {
      return 1;
    } elsif (($args{mon1} == $mon) && ($args{day1} <= $mday)) {
      return 1;
    } elsif (($args{mon2} == $mon) && ($args{day2} >= $mday)) {
      return 1;
    } else {
      return 0;
    }
    return 0;
  } elsif (exists($args{year1}) && exists($args{year2})) {
    foreach my $tyear ($args{year1}..$args{year2}) {
      return 1 if ($tyear == $year);
    }
    return 0;
  } elsif (exists($args{mon1}) && exists($args{mon2})) {
    foreach my $tmon ($args{mon1}..$args{mon2}) {
      return 1 if ($tmon == $mon);
    }
    return 0;
  } elsif (exists($args{day1}) && exists($args{day2})) {
    foreach my $tmday ($args{day1}..$args{day2}) {
      return 1 if ($tmday == $mday);
    }
    return 0;
  } elsif (exists($args{year1})) {
    return (($args{year1} == $year) ? 1 : 0);
  } elsif (exists($args{mon1})) {
    return (($args{mon1} == $mon) ? 1 : 0);
  } elsif (exists($args{day1})) {
    return (($args{day1} == $mday) ? 1 : 0);
  } else {
    return 0;
  }

  return 0;

}


##############################################################################
#
# timeRange - PAC command to see if the current time falls within a range.
#
##############################################################################
sub timeRange {
  my %args;
  my $dayCount = 1;
  my $monCount = 1;
  my $yearCount = 1;

  $args{gmt} = pop(@_) if ($_[$#_] eq "GMT");

  if ($#_ == 0) {
    $args{hour1} = shift;
  } elsif ($#_ == 1) {
    $args{hour1} = shift;
    $args{hour2} = shift;
  } elsif ($#_ == 3) {
    $args{hour1} = shift;
    $args{min1} = shift;
    $args{hour2} = shift;
    $args{min2} = shift;
  } elsif ($#_ == 5) {
    $args{hour1} = shift;
    $args{min1} = shift;
    $args{sec1} = shift;
    $args{hour2} = shift;
    $args{min2} = shift;
    $args{sec2} = shift;
  }

  my $sec = (exists($args{gmt}) ? (gmtime)[0] : (localtime)[0]);
  my $min = (exists($args{gmt}) ? (gmtime)[1] : (localtime)[1]);
  my $hour = (exists($args{gmt}) ? (gmtime)[2] : (localtime)[2]);

  if (exists($args{sec1}) && exists($args{min1}) && exists($args{hour1}) &&
      exists($args{sec2}) && exists($args{min2}) && exists($args{hour2})) {

    if (($args{hour1} < $hour) && ($args{hour2} > $hour)) {
      return 1;
    } elsif (($args{hour1} == $hour) && ($args{min1} <= $min)) {
      return 1;
    } elsif (($args{hour2} == $hour) && ($args{min2} >= $min)) {
      return 1;
    } else {
      return 0;
    }
    return 0;


  } elsif (exists($args{min1}) && exists($args{hour1}) &&
	   exists($args{min2}) && exists($args{hour2})) {
    if (($args{hour1} < $hour) && ($args{hour2} > $hour)) {
      return 1;
    } elsif (($args{hour1} == $hour) && ($args{min1} < $min)) {
      return 1;
    } elsif (($args{hour2} == $hour) && ($args{min2} > $min)) {
      return 1;
    } elsif (($args{hour1} == $hour) && ($args{min1} == $min) &&
	     ($args{sec1} <= $sec)) {
      return 1;
    } elsif (($args{hour2} == $hour) && ($args{min2} == $min) &&
	     ($args{sec2} >= $sec)) {
      return 1;
    } else {
      return 0;
    }
    return 0;
  } elsif (exists($args{sec1}) && exists($args{min1}) &&
	   exists($args{sec2}) && exists($args{min2})) {
    if (($args{min1} < $min) && ($args{min2} > $min)) {
      return 1;
    } elsif (($args{min1} == $min) && ($args{sec1} <= $sec)) {
      return 1;
    } elsif (($args{min2} == $min) && ($args{sec2} >= $sec)) {
      return 1;
    } else {
      return 0;
    }
    return 0;
  } elsif (exists($args{hour1}) && exists($args{hour2})) {
    foreach my $thour ($args{hour1}..$args{hour2}) {
      return 1 if ($thour == $hour);
    }
    return 0;
  } elsif (exists($args{min1}) && exists($args{min2})) {
    foreach my $tmin ($args{min1}..$args{min2}) {
      return 1 if ($tmin == $min);
    }
    return 0;
  } elsif (exists($args{sec1}) && exists($args{sec2})) {
    foreach my $tsec ($args{sec1}..$args{sec2}) {
      return 1 if ($tsec == $sec);
    }
    return 0;
  } elsif (exists($args{hour1})) {
    return (($args{hour1} == $hour) ? 1 : 0);
  } elsif (exists($args{min1})) {
    return (($args{min1} == $min) ? 1 : 0);
  } elsif (exists($args{sec1})) {
    return (($args{sec1} == $sec) ? 1 : 0);
  } else {
    return 0;
  }

  return 0;

}
