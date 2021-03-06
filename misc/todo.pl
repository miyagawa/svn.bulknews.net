#!/usr/bin/env perl
use strict;
use warnings;

=head1 DESCRIPTION

This is a simple command-line interface to Hiveminder that loosely
emulates the interface of Lifehacker.com's todo.sh script.

=cut

use Encode ();
use YAML ();
use LWP::UserAgent;
use Number::RecordLocator;
use Getopt::Long;
use Pod::Usage;
use Email::Address;
use Fcntl qw(:mode);
use File::Temp;

our $CONFFILE = "$ENV{HOME}/.hiveminder";
our $VERSION = 0.92;
our %config = ();
our $ua = LWP::UserAgent->new;
our $locator = Number::RecordLocator->new();
our $default_query = "not/complete/starts/before/tomorrow/accepted/but_first/nothing";
our $unaccepted_query = "unaccepted/not/complete";
our $requests_query = "requestor/me/not/owner/me/not/complete";
our %args;

$ua->cookie_jar({});

# Load the user's proxy settings from %ENV
$ua->env_proxy;

my $encoding;
eval {
    require Term::Encoding;
    $encoding = Term::Encoding::get_encoding();
};
$encoding ||= "utf-8";

binmode STDOUT, ":encoding($encoding)";

main();

sub main {
    GetOptions(\%args,
               "tags=s",
               "tag=s@", "group=s",
               "priority|pri=s",
               "due=s",
               "hide=s",
               "owner=s",
               "help",
               "version",
               "config=s",)
      or pod2usage(2);

    $CONFFILE = $args{config} if $args{config};

    pod2usage(0) if $args{help};
    if ($args{version}) {
        version();
        exit();
    }

    setup_config();

    push @{$args{tag}}, split /\s+/, $args{tags} if $args{tags};

    if($args{priority}) {
        $args{priority} = priority_from_string($args{priority})
          unless $args{priority} =~ /^[1-5]$/;
        die("Invalid priority: $args{priority}")
          unless$args{priority} =~ /^[1-5]$/;
    }

    $args{owner} ||= "me";

    do_login() or die("Bad username/password -- edit $CONFFILE and try again.");

    my %commands = (
        list      => \&list_tasks,
        ls        => \&list_tasks,
        add       => \&add_task,
        do        => \&do_task,
        done      => \&do_task,
        del       => \&del_task,
        rm        => \&del_task,
        edit      => \&edit_task,
        tag       => \&tag_task,
        unaccepted   => sub {list_tasks($unaccepted_query)},
        accept    => \&accept_task,
        decline   => \&decline_task,
        assign    => \&assign_task,
        requests  => sub {list_tasks($requests_query)},
        hide      => \&hide_task,
        comment   => \&comment_task,
        dl        => \&download_textfile,
        download  => \&download_textfile,
        ul        => \&upload_textfile,
        upload    => \&upload_textfile,
        bd        => \&braindump,
        braindump => \&braindump,
        editdump  => \&editdump,
       );
    
    my $command = shift @ARGV || "list";
    $commands{$command} or pod2usage(-message => "Unknown command: $command", -exitval => 2);

    $commands{$command}->();
}


=head1 CONFIG FILE

These methods deal with loading the config file, and populating it
with selections read from the terminal on our first run.

Named searches can be added to the config with a snippet like the following:

  named_searches:
    something: "due before today tag stuff"

=cut

sub setup_config {
    check_config_perms() unless($^O eq 'MSWin32');
    load_config();
    check_config();

}

sub check_config_perms {
    return unless -e $CONFFILE;
    my @stat = stat($CONFFILE);
    my $mode = $stat[2];
    if($mode & S_IRGRP || $mode & S_IROTH) {
        warn("Config file $CONFFILE is readable by someone other than you, fixing.");
        chmod 0600, $CONFFILE;
    }
}

sub load_config {
    return unless(-e $CONFFILE);
    %config = %{YAML::LoadFile($CONFFILE) || {}};
    my $sid = $config{sid};
    if($sid) {
        my $uri = URI->new($config{site});
        $ua->cookie_jar->set_cookie(0, 'JIFTY_SID_HIVEMINDER',
                                    $sid, '/', $uri->host, $uri->port,
                                    0, 0, undef, 1);
    }
    if($config{site}) {
        # Somehow, localhost gets normalized to localhost.localdomain,
        # and messes up HTTP::Cookies when we try to set cookies on
        # localhost, since it doesn't send them to
        # localhost.localdomain.
        $config{site} =~ s/localhost/127.0.0.1/;
    }
}

sub check_config {
    new_config() unless $config{email};
}

sub new_config {
    print <<"END_WELCOME";
Welcome to todo.pl! before we get started, please enter your
Hiveminder username and password so we can access your tasklist.

This information will be stored in $CONFFILE, 
should you ever need to change it.

END_WELCOME

    $config{site} ||= 'http://hiveminder.com';

    while (1) {
        local $| = 1; # Flush buffers immediately
        print "First, what's your email address? ";
        $config{email} = <stdin>;
        chomp($config{email});

        use Term::ReadKey;
        print "And your password? ";
        ReadMode('noecho');
        $config{password} = <stdin>;
        chomp($config{password});
        ReadMode('restore');

        print "\n";

        last if do_login();
        print "That combination doesn't seem to be correct. Try again?\n";
    }

    save_config();
}

sub save_config {
    YAML::DumpFile($CONFFILE, \%config);
    chmod 0600, $CONFFILE;
}

sub version {
    print "This is hiveminder.com's todo.pl version $VERSION\n";

}


=head1 TASKS

methods related to manipulating tasks -- the meat of the script.

=cut

sub list_tasks {
    my $query = shift || $default_query;

    if( scalar @ARGV ){
        $query = join '/', @ARGV;
    }

    #substitute actual query if this is a named search.
    if( defined $config{named_searches}->{$query} ){
        $query = $config{named_searches}->{$query};
        $query =~ s!\s+!/!g;
    }

    my $tag;
    $query .= "/tag/$tag" while $tag = shift @{$args{tag}};

    for my $key qw(group priority due) {
        $query .= "/$key/$args{$key}" if $args{$key};
    }

    $query .= "/owner/$args{owner}";

    my $tasks = download_tasks($query);
    if (@$tasks == 0)
    {
        print "You have no matching tasks.\n";
        return;
    }
 
    for my $t (@$tasks) {
        printf "#%4s ", $locator->encode($t->{id});
        print '(' . priority_to_string($t->{priority}) . ') ' if $t->{priority} != 3;
        print "(Due " . $t->{due} . ") " if $t->{due};
        print $t->{summary};
        if($t->{tags}) {
            print ' [' . $t->{tags} . ']';
        }

        $t->{owner} =~ s/<nobody>/<nobody\@localhost>/;
        $t->{requestor} =~ s/<nobody>/<nobody\@localhost>/;
        
        my ($owner) = Email::Address->parse($t->{owner});
        my ($requestor) = Email::Address->parse($t->{requestor});

        my $not_owner = lc $owner->address ne lc $config{email};
        my $not_requestor = lc $requestor->address ne lc $config{email};
        if( $t->{group} || $not_owner || $not_requestor ) {
            print ' (';
            print join(", ",
                       $t->{group} || "personal",
                       $not_requestor ? "for " . $requestor->name : (),
                       $not_owner ? "by " . $owner->name : (),
                      );
            print ')';
        }
        
        print "\n";
    }
}

sub do_task {
    my $task = get_task_id('complete');
    my $result = call(UpdateTask =>
                      id         => $task,
                      complete   => 1);
    result_ok($result, "Finished task");
}

sub add_task {
    my $summary = join(" ",@ARGV) or pod2usage(-message => "Must specify a task description");
    my %task = %{args_to_task()};
    $task{summary} = $summary;
    $task{owner_id} = $config{email};


    my $result = call(CreateTask => %task);
    result_ok($result, "Created task");
}

sub edit_task {
    my $task = get_task_id('edit');
    my $summary = join(" ",@ARGV);
    my %task = %{args_to_task()};
    $task{id} = $task;
    $task{summary} = $summary if $summary;

    my $result = call(UpdateTask => %task);
    result_ok($result, "Updated task");
}

sub tag_task {
    my $task = get_task_id('tag');
    my @tags = @ARGV;

    my $tasks = download_tasks("id/" . $locator->encode($task));
    my $tags = $tasks->[0]{tags} ||'';

    my $result = call(UpdateTask =>
                      id      => $task,
                      tags    => $tags . " " . join_tags(@tags));

    result_ok($result, "Tagged task");
}

sub del_task {
    my $task = get_task_id('delete');
    my $result = call(DeleteTask => id => $task);

    result_ok($result, "Deleted task");
}

sub accept_task {
    my $task = get_task_id('accept');
    my $result = call(UpdateTask =>
                      id       => $task,
                      accepted => 'TRUE');
    result_ok($result, "Accepted task");
}


sub decline_task {
    my $task = get_task_id('accept');
    my $result = call(UpdateTask =>
                      id       => $task,
                      accepted => 'FALSE');
    result_ok($result, "Declined task");
}

sub assign_task {
    my $task = get_task_id('assign');
    my $owner = shift @ARGV or die('Need an owner to assign task to');
    my $result = call(UpdateTask => id => $task, owner_id => $owner);
    result_ok($result, "Assigned task to $owner");
}

sub hide_task {
    my $task = get_task_id('hide');
    my $when = join(" ", @ARGV) or die('Need a date to hide the task until');
    my $result = call(UpdateTask =>
                      id         => $task,
                      starts     => $when);
    result_ok($result, "Hid task until $when");
}

sub comment_task {
    my $task = get_task_id('comment on');
    if(-t STDIN) {
        print "Type your comment now. End with end-of-file or a dot on a line by itself.\n";
    }
    my $comment;
    while(<STDIN>) {
        chomp;
        last if $_ eq ".";
        $comment .= "\n$_";
    }

    my $result = call(UpdateTask =>
                      id         => $task,
                      comment    => $comment);
    result_ok($result, "Commented on task");
}

sub get_task_id {
    my $action = shift;
    my $task = shift @ARGV or pod2usage(-message => "Need a task-id to $action.");
    return $locator->decode($task) or die("Invalid task ID");
}

sub download_textfile {
    my $query = shift || $default_query;
    my $filename = shift || shift @ARGV || 'tasks.txt';

    my $tag;
    $query .= "/tag/$tag" while $tag = shift @{$args{tag}};

    for my $key qw(group priority due) {
        $query .= "/$key/$args{$key}" if $args{$key};
    }

    $query .= "/owner/$args{owner}";

    my $result = call(DownloadTasks =>
                      query  => $query,
                      format => 'sync');

    # perl automatically does TRT with $filename eq '-'
    open (my $file, ">:utf8", $filename) || die("Can't open file '$filename': $!");

    print $file $result->{_content}{result};
}

sub upload_textfile {
    my $filename = shift || shift @ARGV;
    pod2usage(-message => "Need to specify a file to upload.",
              -exitval => 1
    ) unless $filename;

    open (my $file, "< $filename"); 

    local $/;
    my $content = <$file>;

    my $result = call(UploadTasks =>
                        content => $content,
                        format => 'sync' );

    result_ok( $result, $result->{message} );
}

sub braindump {
    my $fill_file = shift || sub {};

    my $editor = $ENV{EDITOR} || $ENV{VISUAL};
    pod2usage(-message => "You need to specify a texteditor as \$EDITOR or \$VISUAL.",
              -exitval => 1
    ) unless $editor;

    my $fh = File::Temp->new( UNLINK => 0 );
    my $fn = $fh->filename;
    $fh->close;

    $fill_file->( $fn );

    # Call the editor with the file as the first arg
    system( "$editor $fn" );
    upload_textfile( $fn );
    unlink $fn;
}

sub editdump {
  my $query = shift || $default_query;
  braindump( sub { download_textfile( $query, shift ) } )
}

=head1 BTDT API

These functions deal with calling the BTDT/Jifty api to communicate
with the server.

=cut

sub do_login {
    return 1 if $config{sid};
    my $result = call(Login =>
                      address  => $config{email},
                      password => $config{password});
    if(!$result->{failure}) {
        $config{sid} = get_session_id();
        save_config();
        return 1;
    }
    return;
}

sub get_session_id {
    return undef unless $ua->cookie_jar->as_string =~ /JIFTY_SID_HIVEMINDER=([^;]+)/;
    return $1;
}

sub download_tasks {
    my $query = shift || $default_query;

    my $result = call(DownloadTasks =>
                      query  => $query,
                      format => 'yaml');
    return YAML::Load($result->{_content}{result});
}

sub call ($@) {
    my $class   = shift;
    my %args    = (@_);
    my $moniker = 'fnord';

    my $res = $ua->post(
        $config{site} . "/__jifty/webservices/yaml",
        {   "J:A-$moniker" => $class,
            map { ( "J:A:F-$_-$moniker" => $args{$_} ) } keys %args
        }
    );

    if ( $res->is_success ) {
        return YAML::Load( Encode::decode_utf8($res->content) )->{$moniker};
    } else {
        die $res->status_line;
    }
}

=head2 result_ok RESULT, MESSAGE

Make sure that a result returned by C<call> indicates success. If so,
print MESSAGE.  If MESSAGE is a subroutine reference, execute it to get
the message. Otherwise, die with a descriptive error.

=cut

sub result_ok {
    my $result = shift;
    my $message = shift;

    if(!$result->{failure}) {
        print ref($message) ? $message->() . "\n" : "$message\n";
    } else {
        die(YAML::Dump($result));
    }
    
}

=head2 PRIORITY

Conversions between text priorities ('A' - 'Z'), and the 1-5 integer
scale Hiveminder uses internally.

=cut

sub priority_to_string {
    my $pri = shift;
    return chr(ord('A') + 5 - $pri);
}

sub priority_from_string {
    my $pri = lc shift;
    return 5 + ord('a') - ord($pri) if $pri =~ /^[a-e]$/;
    my %primap = (
        lowest  => 1,
        low     => 2,
        normal  => 3,
        high    => 4,
        highest => 5
       );
    return $primap{$pri} || $pri;
}

=head2 args_to_task

Convert argument passed on the command-line into a hash appropriate
for passing as arguments to BTDT actions.

=cut

sub args_to_task {
    my %task;

    $task{tags} = join_tags(@{$args{tag}}) if $args{tag};
    $task{group_id} = $args{group} if $args{group};
    $task{priority} = $args{priority} if $args{priority};
    $task{due} = $args{due} if $args{due};
    $task{starts} = $args{hide} if $args{hide};
    
    return \%task;
}

sub join_tags {
    my @tags = @_;
    return join(" ", map {'"' . $_ . '"'} @tags);
}

__END__

=head1 NAME

todo.pl - a command-line interface to Hiveminder

=head1 SYNOPSIS

  todo.pl [options] list [query]
  todo.pl [options] add <summary>
  todo.pl [options] edit <task-id> [summary]

  todo.pl tag <task-id> tag1 tag2

  todo.pl done <task-id>
  todo.pl del|rm <task-id>

  todo.pl [options] unaccepted
  todo.pl accept <task-id>
  todo.pl decline <task-id>

  todo.pl assign <task-id> <email>
  todo.pl [options] requests

  todo.pl hide <task-id> date

  todo.pl comment <task-id>

  todo.pl [options] download [file]
  todo.pl upload <file>
  todo.pl braindump
  todo.pl [options] editdump

    Options:
       --group                          Operate on tasks in a group
       --tag                            Operate on tasks with a given tag
       --pri                            Operate on tasks with a given priority
       --due                            Operate on tasks due on a given day
       --hide                           Operate on tasks hidden until this day
       --owner                          Operate on tasks with a given owner


  todo.pl list
        List all tasks in your todo list.
  
  todo.pl list due before today not complete
        List tasks that are overdue.
  
  todo.pl list important
        Lists tasks specified by the named search 'important'.
        For more on named searches, see the CONFIG FILE section of the perldoc

  todo.pl --tag home --tag othertag --group personal list
        List personal tasks not in a group with tags 'home' and 'othertag'.

  todo.pl --tag cli --group hiveminders edit 3G Implement todo.pl
        Move task 3G into the hiveminders group, set its tags to
        "cli", and change the summary.

  todo.pl --tag "" 4J
        Delete all tags from task 4J

  todo.pl tag 4J home
        Add the tag 'home' to task 4J

  todo.pl braindump
        Open up $EDITOR to braindump tasks

  todo.pl --tag sometag editdump
        Download and edit tasks with tag 'sometag'.
        Updates tasks after $EDITOR completes.


This software is Copyright 2006-2008 Best Practical Solutions, LLC

You may use, modify and redistribute it however you'd like to.
Feel free to fold, spindle or mutilate it, too.

=head1 CONTRIBUTORS

Marc Dougherty <muncus@gmail.com>
 added support for named queries, and queries on the commandline

=cut
