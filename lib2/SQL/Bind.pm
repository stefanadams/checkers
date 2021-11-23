package SQL::Bind;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT_OK = qw(sql);
 
our $VERSION = '1.03';
 
our $PlaceholderPrefix = ':';
our $PlaceholderRegex  = qr/(?i)([a-z_][a-z0-9_]*)/;
 
sub sql {
    my ($sql, %params) = @_;
 
    my @bind;
 
    my $exceptions = '';
 
    if ($PlaceholderPrefix eq ':') {
        $exceptions = '(?<!:)';
    }
 
    $sql =~ s{$exceptions${PlaceholderPrefix}${PlaceholderRegex}(!|\*)?}{
        my $options = $2
          ? {
            {
                '!' => 'raw',
                '*' => 'recursive'
            }->{$2} => 1
          }
          : {};
        my ($replacement, @subbind) = _replace($1, $options, %params);
 
        push @bind, @subbind;
 
        $replacement;
    }ge;
 
    return ($sql, @bind);
}
 
sub _replace {
    my ($placeholder, $options, %params) = @_;
 
    my @bind;
 
    my $replacement = '';
 
    if (!exists $params{$placeholder}) {
        die sprintf 'unknown placeholder: %s', $placeholder;
    }
 
    if (ref $params{$placeholder} eq 'HASH') {
        if ($options->{raw}) {
            $replacement = join ', ', map { $_ . '=' . $params{$placeholder}->{$_} }
              keys %{$params{$placeholder}};
        }
        else {
            $replacement = join ', ', map { $_ . '=?' } keys %{$params{$placeholder}};
            push @bind, values %{$params{$placeholder}};
        }
    }
    elsif (ref $params{$placeholder} eq 'ARRAY') {
        if ($options->{raw}) {
            $replacement = join ', ', @{$params{$placeholder}};
        }
        else {
            $replacement = join ', ', map { '?' } 1 .. @{$params{$placeholder}};
            push @bind, @{$params{$placeholder}};
        }
    }
    else {
        if ($options->{raw}) {
            $replacement = $params{$placeholder};
        }
        elsif ($options->{recursive}) {
            my ($subsql, @subbind) = sql($params{$placeholder}, %params);
 
            $replacement = $subsql;
            push @bind, @subbind;
        }
        else {
            $replacement = '?';
            push @bind, $params{$placeholder};
        }
    }
 
    return ($replacement, @bind);
}

1;