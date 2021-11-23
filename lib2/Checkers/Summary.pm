package Checkers::Summary;
use Mojo::Base -base, -signatures;

my @cols = qw(group category check pass fail);
has [@cols];

1;