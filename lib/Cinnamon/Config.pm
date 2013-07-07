package Cinnamon::Config;
use strict;
use warnings;

use Cinnamon::Config::Loader;
use Cinnamon::Logger;

my %CONFIG;
my %TASKS;

sub reset () {
    %CONFIG = ();
    %TASKS  = ();
}

sub set ($$) {
    my ($key, $value) = @_;

    $CONFIG{$key} = $value;
}

sub get ($@) {
    my ($key, @args) = @_;

    my $value = $CONFIG{$key};

    $value = $value->(@args) if ref $value eq 'CODE';
    $value;
}

sub set_task ($$) {
    my ($task, $task_def) = @_;
    $TASKS{$task} = $task_def;
}

sub get_task (@) {
    my ($task) = @_;

    $task ||= get('task');
    my @task_path = split(':', $task);

    my $value = \%TASKS;
    for (@task_path) {
        $value = $value->{$_};
    }

    $value;
}

sub user () {
    get 'user' || do {
        my $user = qx{whoami};
        chomp $user;
        $user;
    };
}

sub load (@) {
    my ($role, $task, %opt) = @_;

    set role => $role;
    set task => $task;

    Cinnamon::Config::Loader->load(config => $opt{config});

    for my $key (keys %{ $opt{override_settings} }) {
        set $key => $opt{override_settings}->{$key};
    }
}

sub info {
    my $self  = shift;

    +{
        tasks => \%TASKS,
    }
}

!!1;
