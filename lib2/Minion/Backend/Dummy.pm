package Minion::Backend::Dummy;
use Mojo::Base 'Minion::Backend';
 
sub auto_retry_job    { 0 }
sub broadcast         { 0 }
sub dequeue           { {} }
sub enqueue           { undef }
sub fail_job          { 0 }
sub finish_job        { 0 }
sub history           { {} }
sub list_jobs         { {} }
sub list_locks        { {} }
sub list_workers      { {} }
sub lock              { 0 }
sub new               { shift->SUPER::new }
sub note              { 0 }
sub receive           { [] }
sub register_worker   { undef }
sub remove_job        { 0 }
sub repair            { }
sub reset             { }
sub retry_job         { 0 }
sub stats             { {} }
sub unlock            { 0 }
sub unregister_worker { }
 
1;
