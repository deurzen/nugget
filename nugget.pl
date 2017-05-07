#!usr/bin/env perl
use feature ':5.12';
use strict;
use warnings;
use diagnostics;
use File::Copy;
use Term::ANSIColor qw(:constants);
my $VIMSG_DIR = "/var/lib/vimsg/";
my $NUGGET_DIR = "${VIMSG_DIR}nugget/";
my $DELETED_DIR = "${VIMSG_DIR}deleted/";
my $EXTENSION = ".nugget";
my @COMMAND_NAMES = qw(add show edit list remove exec copy);
my %COMMANDS = map { $_ => 1 } @COMMAND_NAMES;
my $PADDING = 14;

sub printcolor {
	print @_, RESET;
}

sub printb {
	printcolor(BLUE, "$_[0]");
}

sub printy {
	printcolor(YELLOW, "$_[0]");
}

sub printp {
	printcolor(MAGENTA, "$_[0]");
}

sub printr {
	printcolor(RED, "$_[0]");
}

sub printg {
	printcolor(GREEN, "$_[0]");
}

sub print_usage {
	printb("usage: nugget [*force] " .
		"(add|show|edit|list|*remove|exec|copy*) name [name*]\n");
	exit;
}

sub print_existence_error {
	printb("a nugget with that name already exists\n");
	exit;
}

sub print_nonexistence_error {
	printb("this nugget does not exist\n");
	exit;
}

sub prompt_user {
	local $| = 1;
	print(@_);
	chomp (my $ANSWER = <STDIN>);
	return $ANSWER;
}

sub prompt_yn {
	my $ANSWER = prompt_user(MAGENTA,"$_[0] [y/N] ",RESET);
	return lc($ANSWER) eq 'y';
}

sub prompt_field {
	local $| = 1;
	printb(": ");
	printr("$_[0]" . spaces($_[0]));
	printb(": ");
	chomp(my $ANSWER = <STDIN>);
	return $ANSWER;
}

sub prompt_fields {
	local $| = 1;
	my @FIELDS;
	push(@FIELDS, prompt_field($_[0]));
	return @FIELDS if ! $FIELDS[0];
	while(my $ANSWER = prompt_user(BLUE,((" " x ($PADDING+2)) . ": "),RESET)) {
		push(@FIELDS, $ANSWER);
	}
	system("printf '\e[A\e[K'");
	return @FIELDS;
}

sub display_field {
	printb(": ");
	printr("$_[0] " . spaces($_[0]));
	printb(": ");
	print("$_[1]");
}

sub display_fields {
	my $FIELD_REF = $_[1];
	my @FIELD = @{$FIELD_REF};
	printb(": ");
	printr("$_[0] " . spaces($_[0]) . (" " x ($_[3] or 0)));
	printb(": ");
	print("$FIELD[0]\n");
	foreach(1 .. scalar(@FIELD)-1) {
		printr(" " x ($PADDING+($_[2] or 3)));
		printb(": ");
		print("$FIELD[$_]\n")
	}
}

sub spaces {
	my $LENGTH = $PADDING - length $_[0];
	return " " x $LENGTH;
}

sub add_nugget_file {
	my $NUGGET_FILE = "${NUGGET_DIR}$_[0]${EXTENSION}";
	print_existence_error() if -f $NUGGET_FILE;
	printb(": ");
	printg("adding nugget");
	printb(spaces("adding nugget") . ": ");
	printy("$_[0]\n");
	my $NUGGET_TITLE = prompt_field("title");
	my $NUGGET_URI = prompt_field("uri");
	my @NUGGET_BODY = prompt_fields("body");
	my $NUGGET_BODY_FIRST = shift(@NUGGET_BODY);
	my @NUGGET_SEQUENCE = prompt_fields("sequence");
	my $NUGGET_SEQUENCE_FIRST = shift(@NUGGET_SEQUENCE);
	system("touch $NUGGET_FILE");
	open(FILE, ">>", $NUGGET_FILE) or
		die "error writing to file: $!\n";
	print(FILE "created:" . spaces("created") . localtime(time) ."\n");
	print(FILE "type:" . spaces("type") . "nugget\n");
	print(FILE "location:" . spaces("location") . "$NUGGET_DIR\n");
	print(FILE "name:" . spaces("name") . "$_[0]\n\n");
	print(FILE "title:" . spaces("title") . "$NUGGET_TITLE\n");
	print(FILE "uri:" . spaces("uri") . "$NUGGET_URI\n\n");
	print(FILE "body:" . spaces("body") . "$NUGGET_BODY_FIRST\n");
	foreach my $NUGGET_BODY_LINE(@NUGGET_BODY) {
		print(FILE (" " x ($PADDING+1)) . "$NUGGET_BODY_LINE\n");
	}
	print(FILE "\nsequence:" . spaces("sequence") .
		"$NUGGET_SEQUENCE_FIRST\n");
	foreach my $NUGGET_SEQUENCE_LINE(@NUGGET_SEQUENCE) {
		print(FILE (" " x ($PADDING+1)) . "$NUGGET_SEQUENCE_LINE\n");
	}
	close(FILE);
	printb("successfully added $_[0]\n");
}

sub edit_nugget_file {
	my $NUGGET_FILE = "${NUGGET_DIR}$_[0]${EXTENSION}";
	print_nonexistence_error() if ! -f $NUGGET_FILE;
	my $EDITOR = defined $ENV{EDITOR} ?
		$ENV{EDITOR} :
		"/usr/bin/vi";
	my $PREV_TIMESTAMP = `stat -c%y $NUGGET_FILE`;
	system("$EDITOR $NUGGET_FILE");
	printb(`stat -c%y $NUGGET_FILE` eq $PREV_TIMESTAMP ?
		"nothing changed\n":
		"successfully written to $_[0]\n");
}

sub remove_nugget_file {
	my $FORCE = $_[0];
	my $NUGGET_FILE = "${NUGGET_DIR}$_[1]${EXTENSION}";
	my $DELETED_FILE = "${DELETED_DIR}$_[1]${EXTENSION}";
	print_nonexistence_error() if ! -f $NUGGET_FILE;
	(move($NUGGET_FILE, $DELETED_FILE) or
		die "removal failed: $!\n") and
			printb("successfully removed $_[1]\n")
				if $FORCE or prompt_yn("remove nugget?");
}

sub show_nugget_file {
	my $NUGGET_FILE = "${NUGGET_DIR}$_[0]${EXTENSION}";
	print_nonexistence_error() if ! -f $NUGGET_FILE;
	printb(": ");
	printg("showing nugget");
	printb(spaces("showing nugget") . " : ");
	printy("$_[0]\n");
	open(FILE, '<:encoding(UTF-8)', $NUGGET_FILE) or
		die "could not open nugget file: $!\n";
	my $NUGGET_TITLE;
	my $NUGGET_URI;
	my @NUGGET_BODY;
	my @NUGGET_SEQUENCE;
	my $LINE_COUNT = 1;
	while(<FILE>) {
		$NUGGET_TITLE = substr($_, ($PADDING+1), length $_) if($LINE_COUNT == 6);
		$NUGGET_URI = substr($_, ($PADDING+1), length $_) if($LINE_COUNT == 7);
		if(/^body:   / .. /^sequence:   /) {
			chomp;
			push(@NUGGET_BODY, substr($_, ($PADDING+1), length $_))
				unless /^(sequence:   |$)/;
		}
		if(/^sequence:   / .. /^$/) {
			chomp;
			push(@NUGGET_SEQUENCE, substr($_, ($PADDING+1), length $_))
				unless /^$/;
		}
		$LINE_COUNT++;
	}
	display_field("title", "$NUGGET_TITLE");
	display_field("uri", "$NUGGET_URI");
	display_fields("body", \@NUGGET_BODY);
	display_fields("sequence", \@NUGGET_SEQUENCE);
	close(FILE);
	printb("successfully displayed $_[0]\n");
}

sub copy_nugget_file {
	my $NUGGET_FILE = "${NUGGET_DIR}$_[0]${EXTENSION}";
	my $NEW_NUGGET_FILE = "${NUGGET_DIR}$_[1]${EXTENSION}";
	print_nonexistence_error() if ! -f $NUGGET_FILE;
	print_existence_error() if -f $NEW_NUGGET_FILE;
	(copy($NUGGET_FILE, $NEW_NUGGET_FILE) or
		die "copy failed: $!\n") and
			printb("successfully copied $_[0] to $_[1]\n");
}

sub exec_nugget_file {
	my $NUGGET_FILE = "${NUGGET_DIR}$_[0]${EXTENSION}";
	print_nonexistence_error() if ! -f $NUGGET_FILE;
	printb(": ");
	printg("executing nugget");
	printb(spaces("showing nugget") . " : ");
	printy("$_[0]\n");
	open(FILE, '<:encoding(UTF-8)', $NUGGET_FILE) or
		die "could not open nugget file: $!\n";
	my @NUGGET_SEQUENCE;
	while(<FILE>) {
		if(/^sequence:   / .. /^$/) {
			chomp;
			push(@NUGGET_SEQUENCE, substr($_, ($PADDING+1), length $_))
				unless /^$/;
		}
	}
	display_fields("sequence", \@NUGGET_SEQUENCE, 5, 2);
	if(prompt_yn("execute sequence?")) {
		foreach my $COMMAND(@NUGGET_SEQUENCE) {
			system("$COMMAND");
		}
	}
	close(FILE);
}

sub list_nugget_files {
	my @FILES;
	opendir(DIR, $NUGGET_DIR) or
		die "could not open nugget directory\n";
	@FILES = @_ ? grep(/$_[0]/, readdir(DIR)) : readdir(DIR);
	foreach my $FILE(@FILES) {
		next if $FILE =~ /^\./;
		(my $NUGGET = $FILE) =~ s/\.[^.]+$//;
		printy("$NUGGET\n");
	}
	closedir(DIR);
}

sub delegate_command {
	my %COMMANDS = (
		add => sub { add_nugget_file($_[2]); },
		show => sub { show_nugget_file($_[2]); },
		edit => sub { edit_nugget_file($_[2]); },
		remove => sub { remove_nugget_file($_[0], $_[2]); },
		exec => sub { exec_nugget_file($_[2]); }
	);
	if (scalar(@_) > 3 and $_[1] eq "copy") {
		copy_nugget_file($_[2], $_[3]);
		exit;
	} elsif (scalar(@_) > 2 and my $COMMAND = $COMMANDS{$_[1]}) {
		$COMMAND->(@_);
		exit;
	} elsif ($_[1] eq "list") {
		scalar(@_) > 2 ?
			list_nugget_files($_[2]) :
			list_nugget_files();
		exit;
	}
	print_usage();
}

sub parse_input {
	my @INPUT;
	my $FORCE = 0;
	if (!@ARGV or $ARGV[0] eq "force") {
		$FORCE = 1;
		shift(@ARGV);
	}
	print_usage() if ! @ARGV;
	my $COMMAND = shift(@ARGV);
	print_usage() if ! exists($COMMANDS{$COMMAND});
	push(@INPUT, $FORCE);
	push(@INPUT, $COMMAND);
	push(@INPUT, @ARGV) if @ARGV;
	return @INPUT;
}

delegate_command(parse_input());

